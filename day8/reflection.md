# Day 8 Reflection

The most difficult concept in this course was designing for correctness when many users perform the same action at the same time. The ticketing example made this clear: two customers can both see a seat as available, but only one must be allowed to reserve it. I overcame this by breaking the problem into a database transaction, a conditional update, and constraints that enforce the rule even when requests arrive concurrently. Working through the request flow also helped me understand why a cache or waiting room cannot replace database-level protection.

One part of my QuickNotes capstone I would improve is the demonstration of real persistence and failure handling. The prototype used JSONPlaceholder, which simulates successful API operations but does not permanently save changes. I would replace it with an Express backend and PostgreSQL, then demonstrate that notes remain after a refresh and show clear behaviour when the API or database is unavailable. This would make the difference between a frontend prototype and a complete application easier to evaluate.

Next, I will learn Node.js and Express, then connect the API to PostgreSQL. After that, I plan to learn React and continue practising system design, especially caching, queues, database consistency, and scaling under heavy traffic.
