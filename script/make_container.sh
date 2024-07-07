docker run --cap-add NET_ADMIN -u root --name direct -it --net janus-1500 --ip 172.20.0.2 -p 5002:5002/udp -p 5004:5004/udp -p 8188:8188 janus:direct
