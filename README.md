# Library Backend API

A Rails API-only backend application for a Library application, containerized with Docker.

### Development Users

* Librarian User:
 > User: librarian@email.com<br>
 > Password: librarian123
* First Member User:
 > User: member@email.com<br>
 > Password: member123
* Second Member User:
 > User: member2@email.com<br>
 > Password: member123

### Main Tecnologies

* Ruby version 3.2.0
* Rails version 8.0.3
* Postgresql version 15.2

### Running Library Backend in development

* Clone repository;
* Ask the "master.key" for repository owner;
* Put "master.key" in config folder;
* In root path of project build the containers:
```sh
docker compose build
```
* To create, migrate and seed database:
```sh
docker compose run --rm web rails db:setup
```
* To access Rails console:
```sh
docker compose run --rm web rails c
```
* To run the application:
```sh
docker compose up
```
* Application runs in http://localhost:3000

### Tests

* Using [rspec](https://rspec.info) for tests.
* To run all tests:
```sh
docker compose run --rm web rspec
```

## Database ER Diagram

```mermaid
erDiagram
    USERS {
        bigint id PK
        string name
        string email UK
        string encrypted_password
        integer role
        string reset_password_token UK
        datetime reset_password_sent_at
        datetime remember_created_at
        datetime created_at
        datetime updated_at
        string jti UK
    }
    
    BOOKS {
        bigint id PK
        string title
        string author
        string genre
        string isbn
        integer total_copies
        boolean available
        datetime created_at
        datetime updated_at
    }
    
    BORROWS {
        bigint id PK
        bigint borrower_id FK
        bigint book_id FK
        datetime borrowed_at
        datetime due_at
        boolean returned
        datetime created_at
        datetime updated_at
    }
    
    USERS ||--o{ BORROWS : "borrows"
    BOOKS ||--o{ BORROWS : "borrowed_by"
```

