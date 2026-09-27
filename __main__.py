from app import app
import os

app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8000")))
