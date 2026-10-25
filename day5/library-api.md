
# Library Books REST API Design

## Base URL

`https://api.example.com`

Resource: `/books`

## 1. List all books

- **Method:** GET
- **Path:** `/books`
- **Description:** Returns a list of books in the library.
- **Success status:** `200 OK`
- **Example request body:** None.

## 2. Get one book

- **Method:** GET
- **Path:** `/books/42`
- **Description:** Returns the details of the book with ID 42.
- **Success status:** `200 OK`
- **Example request body:** None.

## 3. Create a book

- **Method:** POST
- **Path:** `/books`
- **Description:** Adds a new book to the library.
- **Success status:** `201 Created`
- **Example request body:**

```json
{
  "title": "Things Fall Apart",
  "author": "Chinua Achebe",
  "publishedYear": 1958
}
```

## 4. Replace a book

- **Method:** PUT
- **Path:** `/books/42`
- **Description:** Replaces the details of book 42.
- **Success status:** `200 OK`
- **Example request body:**

```json
{
  "title": "Things Fall Apart",
  "author": "Chinua Achebe",
  "publishedYear": 1958
}
```

## 5. Delete a book

- **Method:** DELETE
- **Path:** `/books/42`
- **Description:** Deletes book 42 from the library.
- **Success status:** `204 No Content`
- **Example request body:** None.

## 6. List books by author

- **Method:** GET
- **Path:** `/books?author=Chinua%20Achebe`
- **Description:** Returns books written by Chinua Achebe.
- **Success status:** `200 OK`
- **Example request body:** None. The author is supplied as a query parameter.

## 7. Partially update a book

- **Method:** PATCH
- **Path:** `/books/42`
- **Description:** Updates selected fields of book 42 without replacing the entire resource.
- **Success status:** `200 OK`
- **Example request body:**

```json
{
  "title": "Updated Book Title"
}
```

## Error responses

### 400 Bad Request

- **Meaning:** The request is invalid or contains incorrect data.
- **Example:** A create-book request is missing the required `title` field.

### 404 Not Found

- **Meaning:** The requested resource does not exist.
- **Example:** A request to `GET /books/9999` when no book has that ID.
