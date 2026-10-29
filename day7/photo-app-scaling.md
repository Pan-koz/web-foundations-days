
# Day 7 Assignment: Scaling SnapShare

## 1. Assumptions

SnapShare is a photo-sharing application where users upload photos and view a feed containing photos from people they follow.

The following assumptions are used:

- Registered users: 10,000,000.
- Daily active users (DAU): 10% of registered users.
- Each active user uploads one photo per day.
- Each active user views 50 feed pages per day.
- Average original photo size: 2 MB.
- Average thumbnail size: 50 KB.
- One day is approximated as 100,000 seconds for request-rate calculations.
- Peak traffic is estimated at five times the average traffic.
- Each feed page view is counted as one feed request.
- Storage estimates use decimal units and exclude backups, replicas, metadata, and overhead.

### Daily active users

DAU = 10,000,000 × 10% = 1,000,000 users.

## 2. Traffic and storage estimates

### Photo uploads

Daily uploads = 1,000,000 users × 1 photo = 1,000,000 uploads/day.

Average uploads per second = 1,000,000 ÷ 100,000 = 10 uploads/second.

Peak uploads per second = 10 × 5 = 50 uploads/second.

### Feed views

Daily feed views = 1,000,000 users × 50 views = 50,000,000 views/day.

Average feed views per second = 50,000,000 ÷ 100,000 = 500 views/second.

Peak feed views per second = 500 × 5 = 2,500 views/second.

### Storage per year

Original photos per day = 1,000,000 × 2 MB = 2,000,000 MB = 2 TB/day.

Original photo storage per year = 2 TB × 365 = 730 TB/year.

Thumbnails per day = 1,000,000 × 50 KB = 50 GB/day.

Thumbnail storage per year = 50 GB × 365 = 18.25 TB/year.

Total photo and thumbnail storage per year = 730 TB + 18.25 TB = 748.25 TB/year.

These estimates assume that all daily uploads are retained for a full year. Actual storage requirements will be higher when backups, replicas, metadata, and other overhead are included.

## 3. Read-heavy or write-heavy?

SnapShare is a read-heavy system because it receives approximately 50 feed views for every photo upload.

The design should optimize feed delivery with caching, database read replicas, and a content delivery network (CDN). The application should also process thumbnail creation asynchronously so that uploading a photo does not require the user to wait for image processing to finish.

## 4. Where should photos be stored?

Photo files should be stored in object storage rather than directly inside a relational database.

Object storage is designed for large files, scales independently from the database, and works well with CDNs. Storing large image binaries in the database would increase database size, backup costs, and query overhead.

The database should store photo metadata, such as the photo ID, owner ID, caption, upload timestamp, object-storage key, thumbnail key, and visibility settings. The actual image files should be stored in object storage, such as Amazon S3 or an equivalent service.

## 5. Architecture diagram

```text
                     Users / Browsers
                            |
             +--------------+--------------+
             |                             |
             v                             v
       +-----------+                 +-------------+
       |    CDN    |                 | Load        |
       | Cached    |                 | Balancer    |
       | images    |                 +-------------+
       +-----------+                        |
             ^                              v
             |                       +---------------+
             |                       | App Servers   |
             |                       | Stateless     |
             |                       +---------------+
             |                         |    |     |
             |                         |    |     +----------------+
             |                         |    |                      |
             |                         v    v                      v
             |                    +--------+  +-------------+  +---------+
             |                    | Cache  |  | Primary DB  |  | Queue   |
             |                    | Redis  |  | Metadata    |  |         |
             |                    +--------+  +-------------+  +---------+
             |                                   |                 |
             |                                   v                 v
             |                              +-----------+     +-----------+
             |                              | Read      |     | Thumbnail |
             |                              | Replica   |     | Worker    |
             |                              +-----------+     +-----------+
             |                                                      |
             |                                                      v
             +-----------------------------------------------+---------------+
                                                             | Object Storage|
                                                             | Originals and |
                                                             | thumbnails    |
                                                             +---------------+
```

The CDN delivers cached images to users. The app servers and workers use object storage for the actual photo files; the database stores metadata and references.

## 6. What each component does

- **CDN:** Serves cached images from geographically distributed edge locations to reduce latency and origin-server load.
- **Load balancer:** Distributes incoming application requests across healthy app servers.
- **Stateless app servers:** Handle authentication, uploads, feed requests, authorization, and business logic without relying on local session state.
- **Redis cache:** Stores frequently accessed feed data and metadata to reduce repeated database queries.
- **Primary database:** Stores photo metadata, user relationships, captions, and other structured records while handling writes.
- **Read replica:** Serves suitable read queries to reduce load on the primary database.
- **Queue:** Holds thumbnail-generation jobs so image processing can happen asynchronously.
- **Thumbnail worker:** Consumes queued jobs, generates smaller image versions, and saves them to object storage.
- **Object storage:** Stores original photos and generated thumbnails durably and independently of the application database.

## 7. Photo upload flow

1. A user selects a photo and submits an upload request.
2. The load balancer routes the request to a healthy app server.
3. The app server authenticates the user, checks authorization, validates the file type and size, and applies upload rate limits.
4. The app server stores the original photo in object storage. A production implementation may instead issue a short-lived, authorized upload URL so the client can upload directly to object storage.
5. The app server records the photo metadata and object-storage key in the primary database.
6. The app server places a thumbnail-generation job on the queue.
7. The server returns a successful response with the photo ID and upload status without waiting for thumbnail processing to finish.
8. A background worker retrieves the job and downloads or reads the original image from object storage.
9. The worker generates a 50 KB thumbnail target, where practical, and saves the thumbnail in object storage.
10. The worker updates the photo metadata with the thumbnail key and marks processing as complete.
11. The CDN can serve the original and thumbnail images using their object-storage origins.
12. The application invalidates or updates affected cached feeds so subsequent reads can show the new photo when appropriate.

The upload workflow should handle failures safely. Jobs can be retried, and workers should be idempotent so retrying a job does not create inconsistent results or duplicate records.

## 8. Trade-offs

### Caching versus data freshness

Caching improves feed response times and reduces database load. However, cached feeds may become stale after a user uploads a photo or changes a follow relationship. Cache invalidation and time-to-live (TTL) settings help balance freshness and performance.

### Database read replicas versus consistency

Read replicas improve read capacity and protect the primary database from heavy read traffic. However, replication lag may cause a newly uploaded photo to be temporarily missing from a feed served by a replica. Recent writes may need to be read from the primary database.

### Asynchronous thumbnails versus immediate availability

A queue allows photo uploads to complete without waiting for thumbnail processing, improving upload responsiveness. However, a thumbnail may not be available immediately, and queue failures or backlogs require monitoring, retries, and recovery mechanisms.

### Object storage and CDN versus cost and control

Object storage and a CDN scale well for large image collections and global delivery. However, storage, requests, and data transfer cost money, and access controls, cache invalidation, and private-photo authorization must be configured carefully.

## 9. Conclusion

SnapShare should use a read-optimized architecture with stateless application servers, a load balancer, Redis caching, a primary database with a read replica, object storage, a CDN, and asynchronous thumbnail workers.

The estimated average load is 10 uploads per second and 500 feed views per second, with estimated peaks of 50 uploads per second and 2,500 feed views per second. Original photos and thumbnails require approximately 748.25 TB of new storage per year before overhead.

The system should be measured and tested under realistic peak traffic before adding more complex infrastructure.
