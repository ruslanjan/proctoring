// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
import {
    Socket
} from "phoenix"
import socket from "./socket"
//
import "phoenix_html"


function call_page() {
    let call_channel = socket.channel("call", {})
    call_channel.join()
        .receive("ok", () => {
            console.log("Successfully joined call channel");
        })
        .receive("error", () => {
            console.log("Unable to join")
        });


    let localStream, peerConnection;
    let localVideo = document.getElementById("localVideo");
    let remoteVideo = document.getElementById("remoteVideo");
    let connectButton = document.getElementById("connect");
    let callButton = document.getElementById("call");
    let hangupButton = document.getElementById("hangup");

    hangupButton.disabled = true;
    callButton.disabled = true;
    connectButton.onclick = connect;
    callButton.onclick = call;
    hangupButton.onclick = hangup;

    function connect() {
        console.log("Requesting local stream");
        navigator.getUserMedia({
            audio: false,
            video: true
        }, gotStream, error => {
            console.log("getUserMedia error: ", error);
        });
    }


    function gotStream(stream) {
        console.log("Received local stream");
        localVideo.srcObject = stream;
        localStream = stream;
        setupPeerConnection();
    }

    async function setupPeerConnection() {
        connectButton.disabled = true;
        callButton.disabled = false;
        hangupButton.disabled = false;
        console.log("Waiting for call");

        let servers = {
            "iceServers": [{
                'urls': 'stun:stun.l.google.com:19302'
            }]
        };

        peerConnection = new RTCPeerConnection(servers);
        console.log("Create local peer connection");
        peerConnection.addEventListener('icecandidate', gotLocalIceCandidate);
        peerConnection.addEventListener('connectionstatechange', event => {
            console.log(peerConnection.connectionState)
            if (peerConnection.connectionState === 'connected') {
                console.log('peers connected')
            }
        });
        peerConnection.onaddstream = gotRemoteStream;
        peerConnection.addStream(localStream);
        console.log("Added localStream to localPeerConnection");
    }


    async function call() {
        callButton.disabled = true;
        console.log("Starting call");

        const offer = await peerConnection.createOffer();
        await peerConnection.setLocalDescription(offer);
        call_channel.push("message", {
            body: JSON.stringify({
                "offer": offer
            })
        });
    }


    function gotRemoteStream(event) {
        remoteVideo.srcObject = event.stream;
        console.log("Received remote stream");
    }


    function gotLocalIceCandidate(event) {
        if (event.candidate) {
            console.log("Local ICE Candidate: \n" + event.candidate.candidate);
            call_channel.push("message", {
                body: JSON.stringify({
                    "iceCandidate": event.candidate
                })
            });
        }
    }

    call_channel.on("message", async payload => {
        let message = JSON.parse(payload.body);
        if (message.answer) {
            const remoteDesc = new RTCSessionDescription(message.answer);
            console.log('got answer')
            await peerConnection.setRemoteDescription(remoteDesc);
        } else if (message.offer) {
            console.log('got offer');
            peerConnection.setRemoteDescription(new RTCSessionDescription(message.offer));
            const answer = await peerConnection.createAnswer();
            await peerConnection.setLocalDescription(answer);
            call_channel.push("message", {
                body: JSON.stringify({
                    "answer": answer
                })
            });
        } else if (message.iceCandidate) {
            console.log('Got ICE Candidate')
            callButton.disabled = true;
            try {
                await peerConnection.addIceCandidate(message.iceCandidate);
            } catch (e) {
                console.error('Error adding received ice candidate', e);
            }
        }
    })

    function hangup() {
        console.log("Ending Call");
        peerConnection.close();
        localVideo.src = null;
        peerConnection = null;
        hangupButton.disabled = true;
        connectButton.disabled = false;
        callButton.disabled = true;
    }


    function handleError(error) {
        console.log(error.name + ": " + error.message);
    }


}

if (document.querySelector('#call-page')) {
    call_page();
}