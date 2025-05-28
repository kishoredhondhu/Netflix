✅ Sample Postman Commands
🔹 Create a Member
POST http://localhost:8080/api/cast-crew

json
Copy
Edit
{
  "name": "Kishore Kumar",
  "role": "Actor",
  "contactEmail": "kishore@example.com",
  "contactPhone": "9998887770",
  "contractStatus": "SIGNED",
  "availabilityDates": ["2025-07-01", "2025-07-05"],
  "contractFileName": "kishore_contract.pdf"
}
🔹 Get All
GET http://localhost:8080/api/cast-crew
