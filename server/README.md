# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


## Documentation

### Authentication

All routes except `POST /users` are protected using [JWT](https://jwt.io).
To obtain an authorization token, send a POST request to `login`: 
```json
// POST /login
{
  "auth": {
    "email": "myemail@provider.com",
    "password": "mypassword"
  }
}
```

The server will answer with either `401 - Unauthorized` if the credentials are incorrect or with : 
```json
{
  "jwt": "token.jwt.encoded"
}
```

You must include the token in each request to a protected route. The token is included with the Authorization header : 
In the HTTP headers, put this : 
```
Authorization: Bearer token
```
Where `token` is the jwt token previously obtained.


### Routes

| Prefix    | Verb  | URI Pattern               | Controller#Action | 
| :---------: | :-----: | :-------------------------: | :-----------------: |
| tags      |  GET  |  /tags                    | tags#index |
|           | POST  | /tags                     | tags#create | 
| tag       | GET   | /tags/:id                 | tags#show |
|           | PATCH | /tags/:id                 | tags#update |
|           | PUT   | /tags/:id                 | tags#update |
|           | DELETE| /tags/:id                 | tags#destroy |
| users     | GET   | /users                    | users#index |
|           | POST  | /users                    | users#create |
| user      | GET   | /users/:id                | users#show |
|           | PATCH | /users/:id                | users#update |
|           | PUT   | /users/:id                | users#update |
|           | DELETE| /users/:id                | users#destroy |
| works     | GET   | /works                    | works#index |
|           | POST  | /works                    | works#create |
| work      | GET   | /works/:id                | works#show |
|           | PATCH | /works/:id                | works#update |
|           | PUT   | /works/:id                | works#update |
|           | DELETE| /works/:id                | works#destroy |
|           | POST  | /users/:id/tags           | users#create_tags |
|           | DELETE| /users/:id/tags/:tag_id   | users#destroy_tags           |
|           | POST  | /works/:id/users          |works#bind_participants        |
|           | DELETE| /works/:id/users/:user_id | works#unbound_participants    |
|           | POST  | /works/:id/tags           | works#bind_tags               |
|           | DELETE| /works/:id/tags/:tag_id   | works#unbound_tags            |


Details for each resource are defined in the next section

#### Routes details

#### Tags 
 
| Field | Details | 
| :----: | :-----: | 
| name  | Required |  


 ```json
 //POST /tags
 {
  "name": "Tag Example"
 }
 ```


#### Users  

- New Users  

| Field | Details | 
| :----: | :-----: | 
| pseudo | Required |
| email | Required, must be a valid email |
| password | Required |
| password_confirmation | Required |
| website | Optional

```json
// POST /users
{
  "pseudo": "Pseudo Example",
  "email" : "example@example.com",
  "passord": "password",
  "password_confirmation": "password",
  "website": "https://superwebsite.com" 
}
```


- Create tags for a specific user  

  > :warning: You can only modify tags of the logged in user ! To modify the other users, you must log as each user !


| Field | Details | 
| :----: | :-----: | 
| tag_id | Id referencing tags, can be an array |

```json
//POST /users/:id/tags
{
  "tag_id": 1
}
```

or 
```json
//POST /users/:id/tags
{
  "tag_id": [1, 3]
}
```

- Delete a specific tag for a specific user

   > :warning: You can only modify tags of the logged in user ! To modify the other users, you must log as each user !

  `DELETE /users/:id/tags/:tag_id `

  `:tag_id must be the id of a tag existing for the current user. 

#### Works

| Field | Details | 
| :----: | :-----: | 
| name | Required |
| desc | Required |
| user_id | Required, References an existing user |

```json
//POST /works
{
  "name": "Project Example",
  "desc": "An simple project",
  "user_id": 1
}
```

> :warning: Only the creator of the work will be able to modify it later

- Associate users to a specific work

 | Field | Details | 
 | :----: | :-----: | 
 | user_id | Id referencing users, can be an array |
 
 ```json
 //POST /works/:id/users
 {
  "user_id": 1
 }
 ```
 
 or 
 ```json
 //POST /works/:id/users
 {
   "users_id": [1, 3]
 }
 ``` 
 
 -  Remove a specific user to a specific work
 
 > :warning: You can only remove the logged in user from a project ! To modify the other users, you must log as each user !

`DELETE /works/:id/users/:user_id`

`:user_id` must reference a user participating on the work.

- Add tag to a specific work 

> :warning: Only the creator of the project can modify its tags !

| Field | Details | 
| :----: | :-----: | 
| tag_id | Must reference an existing tag, can be an array |

```json
 //POST /works/:id/tags
 {
  "tag_id": 1
 }
 ```
 
 or 
 ```json
 //POST /works/:id/tags
 {
   "tags_id": [1, 3]
 }
 ``` 
 
 - Remove a specific tag from a specific work
 
 `DELETE /works/:id/tags/:tag_id`
 
 `:tag_id` must reference a tag belonging to the work.