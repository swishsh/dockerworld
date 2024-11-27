const express = require("express");
const axios = require("axios");
const { port, host, db, apiUrl} = require("./configuration");
const { connectDb } = require("./helpers/db");
const app = express();

app.get("/test", (req, res) => {
    res.send("Auth server is up!");
});

app.get("/api/currentUser", (req, res) => {
    res.json({
        id: 1234,
        email: "voinea.stefan88@gmail.com"
    })
});

app.get("/test-api", (req, res) => {
    axios.get(apiUrl + '/test-api-data')
        .then(response => {
            res.json({
                "test-with-api-data": true,
                "api-data-contents": response.data
            })
        })
});

const startServer = () => {
    app.listen(port, () => {
        console.log(`Started auth service on ${host}:${port}`);
        console.log(`Auth mongo database is up on ${db}`)
        console.log(`Api url is ${apiUrl}`)
    });
};

connectDb()
    .on('error', console.log)
    .on('disconnected', console.log)
    .once('open', startServer);