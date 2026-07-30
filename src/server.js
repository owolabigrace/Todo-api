const express = require("express");
const mongoose = require("mongoose");
require("dotenv").config();

const todoRoutes = require("./routes/todos");

const app = express();


app.use(express.json());

app.use("/todos", todoRoutes);

mongoose.connect(process.env.MONGO_URL)
.then(() => {
    console.log("MongoDB connected successfully")
})
.catch((err)=>{
    console.log("Mongo connection error:", err)
});

app.get("/",(req,res)=>{
res.json({
message:"Todo API running"
});
});

const PORT = process.env.PORT || 3000;

app.listen(PORT,()=>{
console.log(`Server running on port ${PORT}`);
});