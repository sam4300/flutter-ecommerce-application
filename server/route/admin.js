const express = require("express");
const admin = require("../middlewares/admin_middleware");
const {Product} = require("../models/product");

const adminRouter = express();


adminRouter.post("/admin/add-product", admin, async (req, res) => {
    try {
      const { name, description, images, quantity, price, category } = req.body;
      let product = new Product({
        name,
        description,
        images,
        quantity,
        price,
        category,
      });
      product = await product.save();
      res.json(product);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  adminRouter.get("/admin/get-posts",admin , async (req,res)=>{
    try{
      const products = await Product.find({});
      res.json(products);
    }catch(e){
      res.status(500).json({error:e.message});
    }

  });

  adminRouter.post("/admin/delete-post", admin, async (req, res) => {
    try {
      const { id } = req.body;
      let product = await Product.findByIdAndDelete(id);
      res.json(product);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

module.exports = adminRouter;