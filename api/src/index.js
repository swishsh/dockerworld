const express = require("express");
const mongoose = require("mongoose");
const axios = require("axios");
const { port, host, db, authApiUrl} = require("./configuration");
const { connectDb } = require("./helpers/db");
const {response} = require("express");
const app = express();

const apiSchema = new mongoose.Schema({
    name: String
});
const Api = mongoose.model("Api", apiSchema);

app.get("/test", (req, res) => {
    res.send("Api server is up!");
});

app.get("/api/test-api-data", (req, res) => {
    res.json({
        "success-data-from-api-container": true
    })
});

app.get("/test-auth-api", (req, res) => {
    axios.get(authApiUrl + '/currentUser')
        .then(response => {
            res.json({
                "test-with-current-user": true,
                "current-user-data": response.data
            })
        })
});

const startServer = () => {
    app.listen(port, () => {
        console.log(`Started api service on ${host}:${port}`);
        console.log(`Mongo database is up on ${db}`)
        console.log(`Auth api url is ${authApiUrl}`)

        const api_insert = new Api({name: "first_api_route"});
        api_insert.save(function(err, result) {
           if (err) return console.error(err);
           console.log('test volume change result', result)
        });
    });
};

connectDb()
    .on('error', console.log)
    .on('disconnected', console.log)
    .once('open', startServer);