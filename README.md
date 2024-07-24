# Elixir Blog project

- A dockyard curriculum project

# Technologies:

- Elixir
- Phoenix
- Ecto

# Project features:

- Posts, with a cover image
- Users
- Tags
- Comments
- Authentication + Authorization

# Entity relationship diagram

```mermaid
erDiagram
User {
  string username
  string email
  string password
  string hashed_password
  naive_datetime confirmed_at
}

Post {
    string title
    text content
    date published_on
    boolean visibility
}

CoverImage {
    text url
    id post_id
}

Comment {
  text content
  id post_id
}

Tag {
    string name
}

User |O--O{ Post: ""
Post }O--O{ Tag: ""
Post ||--O{ Comment: ""
Post ||--|| CoverImage: ""
```
