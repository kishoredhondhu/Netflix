When creating a "Movie Project" from my Angular frontend, the genres (a list of strings) are correctly sent in the JSON payload. However, in the Spring Boot backend controller, this genres list is received as null or empty within the MovieProjectDTO object. This leads to genres not being saved to the database for projects created via Angular.

Interestingly, when sending an identical JSON payload (with a populated genres list) via Postman, the genres list is correctly received and processed by the backend, and the genres are saved.
