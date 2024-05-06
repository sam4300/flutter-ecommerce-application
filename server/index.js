const express = require('express');
const mongoose = require('mongoose');

const authRouter = require('./route/auth');
const adminRouter = require('./route/admin');
const DB = "mongodb+srv://thapasamar48:Godamchour@cluster0.ytkwmol.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

const app = express();

const PORT = 3000;

app.use(express.json());
app.use(authRouter);
app.use(adminRouter);

mongoose.connect(DB).then(()=>{
    console.log('connected to mongodb');
}).catch((e)=>{
    console.log(e);
});

app.listen(PORT,"0.0.0.0",()=>{
    console.log(`connected at port ${PORT}`);
});


