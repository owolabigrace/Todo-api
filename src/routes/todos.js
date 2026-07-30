const express = require("express");
const router = express.Router();
const Todo = require("../models/Todo");

// POST /todos
router.post("/", async (req, res) => {
  try {
    const todo = await Todo.create(req.body);
    res.status(201).json(todo);
  } catch (err) {
    res.status(400).json({
      message: err.message
    });
  }
});

module.exports = router;

// GET /todos
router.get("/", async (req, res) => {
  try {
    const todos = await Todo.find();

    res.json(todos);

  } catch (err) {

    res.status(500).json({
      message: err.message
    });

  }
});
// GET /todos/:id
router.get("/:id", async (req, res) => {
  try {
    const todo = await Todo.findById(req.params.id);

    if (!todo) {
      return res.status(404).json({
        message: "Todo not found"
      });
    }

    res.json(todo);

  } catch (err) {

    res.status(500).json({
      message: err.message
    });

  }
});

// PUT /todos/:id
router.put("/:id", async (req, res) => {
  try {
    const todo = await Todo.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!todo) {
      return res.status(404).json({
        message: "Todo not found"
      });
    }

    res.json(todo);

  } catch (err) {
    res.status(400).json({
      message: err.message
    });
  }
});

// DELETE /todos/:id
router.delete("/:id", async (req, res) => {
  try {
    const todo = await Todo.findByIdAndDelete(req.params.id);

    if (!todo) {
      return res.status(404).json({
        message: "Todo not found"
      });
    }

    res.json({
      message: "Todo deleted successfully"
    });

  } catch (err) {

    res.status(500).json({
      message: err.message
    });

  }
});
