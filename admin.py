import json
import requests
import time


URL = "http://127.0.0.1:7088/admin"


def _request(key, data):
    data = {
        "janus": key,
        "transaction": "test",
        "admin_secret": "janusoverlord",
        **data
    }
    return requests.post(URL, json=data)


def get_list_sessions():
    return _request("list_sessions", dict())


def get_list_handles(session_id):
    return _request("list_handles", {"session_id": session_id})


def _request_handle_info(key: str, session_id: int, handle_id: int):
    return _request(key, {"session_id": session_id, "handle_id": handle_id})


def get_handle_info(session_id, handle_id):
    return _request_handle_info("handle_info", session_id, handle_id)


def start_pcap(session_id, handle_id):
    return _request(
        "start_pcap",
        {"session_id": session_id, "handle_id": handle_id, "folder": "/home/janus", "filename": "unencrypt.pcap"}
    )


def stop_pcap(session_id: int, handle_id: int):
    return _request_handle_info("stop_pcap", session_id, handle_id)


def iter_all_session_handle_tuples():
    data = get_list_sessions().json()
    sessions = data["sessions"]
    for sid in sessions:
        data = get_list_handles(sid).json()
        handles = data["handles"]
        yield from ((sid, hid) for hid in handles)


def get_one_session_handle():
    return next(iter_all_session_handle_tuples())


def get_packet_and_nack(tuples):
    nacks = 0
    packets = 0

    for sid, hid in tuples:
        data = get_handle_info(sid, hid).json()
        info = data["info"]["webrtc"]["media"]["v"]
        nacks += info["stats"]["in"]["nacks"]
        packets += info["stats"]["out"]["packets"]

    return packets, nacks


def main():
    tuples = list(iter_all_session_handle_tuples())
    print(f"Find {len(tuples)} tuples")
    p1, n1 = get_packet_and_nack(tuples)
    time.sleep(5)
    p2, n2 = get_packet_and_nack(tuples)
    dp, dn = p2 - p1, n2 - n1
    print(dp, dn, dn / dp if dp else float("nan"))


if __name__ == "__main__":
    main()

