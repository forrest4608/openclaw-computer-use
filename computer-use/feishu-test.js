import * as lark from "@larksuiteoapi/node-sdk";

console.log("Setting up WS client...");
const client = new lark.WSClient({
    appId: "cli_a9028030faf9dbb5",
    appSecret: "zP8rr9Vzw5MUeEmj8oYYxhlMvVS8adoI",
});

await client.start({
    eventDispatcher: new lark.EventDispatcher({}).register({}),
});
console.log("Client started successfully. It will now try to connect and heartbeat...");
setTimeout(() => {
    console.log("Stopping after 30s...");
}, 30000);
