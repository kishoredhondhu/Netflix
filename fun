✅ 1. Add Budget Category
POST /api/budget/category
Headers:

pgsql
Copy
Edit
Content-Type: application/json
Body (raw JSON):

json
Copy
Edit
{
  "categoryName": "Production",
  "projectId": 1
}
🔁 Replace "projectId": 1 with a valid project ID from your database.

✅ 2. Add Budget Line Item
POST /api/budget/line-item
Headers:

pgsql
Copy
Edit
Content-Type: application/json
Body (raw JSON):

json
Copy
Edit
{
  "itemName": "Camera Rental",
  "estimatedCost": 50000,
  "actualCost": 52000,
  "categoryId": 1
}
🔁 Replace "categoryId": 1 with the ID returned from the /category API.

✅ 3. Get All Budget Categories for a Project
GET /api/budget/project/1
🔁 Replace 1 with the actual project ID.

Returns:

json
Copy
Edit
[
  {
    "id": 1,
    "categoryName": "Production",
    "projectId": 1,
    "lineItems": [
      {
        "id": 1,
        "itemName": "Camera Rental",
        "estimatedCost": 50000,
        "actualCost": 52000,
        "categoryId": 1
      }
    ]
  }
]
✅ 4. Update a Line Item
PUT /api/budget/line-item
Body:

json
Copy
Edit
{
  "id": 1,
  "itemName": "Updated Camera Rental",
  "estimatedCost": 50000,
  "actualCost": 53000,
  "categoryId": 1
}
✅ 5. Delete a Line Item
DELETE /api/budget/line-item/1
🔁 Replace 1 with the line item ID to delete
