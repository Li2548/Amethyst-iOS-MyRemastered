// This script is executed by StikDebug to enable JIT compilation for an app
// It sends the necessary commands to the debug server to enable JIT

// Send attach command
// var response = sendDebugCommand("#b0");
// if(response != "+") {
//     console.log("Failed to enable no ack mode");
//     exit();
// }

// Enable extended mode
var response = sendDebugCommand("#00");
if(response != "+") {
    console.log("Failed to enable extended mode");
    exit();
}

// Enable JIT
var response = sendDebugCommand("#00");
if(response != "+") {
    console.log("Failed to enable JIT");
    exit();
}

console.log("JIT enabled successfully");
