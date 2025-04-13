const express = require('express');
const app = express();
const secret = process.env.APP_SECRET_PARAMETER;

app.get('/', (req, res) => {
  res.send(`<center><h1>Hello from the node-js App for Terraform DevOps Test!<center></h1><br> This is a secret from AWS Parameter Store:<b> ${secret} </b>`);
});

app.listen(3000, () => {
  console.log('App running on port 3000');
});