import sys
import json
import requests
import time
import dataclasses
import argparse
import random
import time
from typing import List, Optional

import numpy as np
import tqdm
import dataclasses_json
from dataclasses_json import config as djs_config
from dataclasses_json import dataclass_json, LetterCase, Undefined

SHOW_DATA_ON_PARSING_ERROR = False

URL = "http://172.20.0.2:7088/admin"
ADMIN_SECRET = "janusoverlord"


def kebab_field():
    return dataclasses.field(metadata=djs_config(letter_case=LetterCase.KEBAB))


def from_fieldname(fieldname: str):
    return dataclasses.field(metadata=djs_config(field_name=fieldname))


@dataclass_json(letter_case=LetterCase.KEBAB)
@dataclasses.dataclass
class JanusResponseInfoFlags:
    got_offer: bool
    got_answer: bool
    negotiated: bool
    processing_offer: bool
    starting: bool
    ice_restart: bool
    ready: bool
    stopped: bool
    alert: bool
    trickle: bool
    all_trickles: bool
    resend_trickles: bool
    trickle_synced: bool
    data_channels: bool
    has_audio: bool
    has_video: bool
    new_datachan_sdp: bool
    rfc4588_rtx: bool = from_fieldname("rfc4588-rtx")
    cleaning: bool
    e2ee: bool


@dataclass_json
@dataclasses.dataclass
class JanusStat:
    packets: int
    bytes: int
    bytes_lastsec: Optional[int] = None
    nacks: Optional[int] = None
    retransmissions: Optional[int] = None


@dataclass_json
@dataclasses.dataclass
class JanusStats:
    i: JanusStat = from_fieldname("in")
    o: JanusStat = from_fieldname("out")


@dataclass_json
@dataclasses.dataclass
class JanusICE:
    stream_id: int
    component_id: int
    state: str
    gathered: int
    connected: int
    local_candidates: List[str] = kebab_field()
    remote_candidates: List[str] = kebab_field()
    selected_pair: str = kebab_field()
    ready: int


@dataclass_json(letter_case=LetterCase.KEBAB)
@dataclasses.dataclass
class JanusDTLS:
    fingerprint: str
    remote_fingerprint: str
    remote_fingerprint_hash: str
    dtls_role: str
    dtls_state: str
    retransmissions: int
    valid: bool
    srtp_profile: str
    ready: bool
    handshake_started: int
    connected: int
    stats: JanusStats


@dataclass_json
@dataclasses.dataclass
class JanusMediumSSRC:
    ssrc: int


@dataclass_json
@dataclasses.dataclass
class JanusMediumDirection:
    send: bool
    recv: bool


@dataclass_json
@dataclasses.dataclass
class JanusMediumCodecs:
    pt: int
    codec: str


@dataclass_json(letter_case=LetterCase.KEBAB)
@dataclasses.dataclass
class JanusMediumRTCPMain:
    base: int
    rtt: int
    lost: int
    lost_by_remote: int
    jitter_local: int
    jitter_remote: int
    in_link_quality: int
    in_media_link_quality: int
    out_link_quality: int
    out_media_link_quality: int


@dataclass_json
@dataclasses.dataclass
class JanusMediumRTCP:
    main: JanusMediumRTCPMain


@dataclass_json
@dataclasses.dataclass
class JanusMedium:
    type: str
    mindex: int
    mid: str
    do_nacks: bool
    nack_queue_ms: int = kebab_field()
    ssrc: JanusMediumSSRC
    direction: JanusMediumDirection
    codecs: JanusMediumCodecs
    rtcp: JanusMediumRTCP
    stats: JanusStats


@dataclass_json
@dataclasses.dataclass
class JanusMedia:
    a: JanusMedium
    v: JanusMedium


@dataclass_json(undefined=Undefined.EXCLUDE)
@dataclasses.dataclass
class JanusWebRTC:
    ice: JanusICE
    dtls: JanusDTLS
    # extensions
    # bwe
    media: JanusMedia


@dataclass_json
@dataclasses.dataclass
class JanusHandleResponseInfo:
    session_id: int
    session_last_activity: int
    session_timeout: int
    session_transport: str
    handle_id: int
    opaque_id: str
    loop_running: bool = kebab_field()
    created: int
    current_time: int
    plugin: str
    flags: JanusResponseInfoFlags
    agent_created: int = kebab_field()
    agent_started: int = kebab_field()
    ice_mode: str = kebab_field()
    ice_role: str = kebab_field()
    queued_packets: int = kebab_field()
    webrtc: JanusWebRTC


@dataclass_json
@dataclasses.dataclass
class JanusResponseBase:
    janus: str
    transaction: str

    @classmethod
    def from_resp(cls, resp):
        data = resp.json()
        try:
            return cls.from_dict(data)
        except KeyError:
            if SHOW_DATA_ON_PARSING_ERROR:
                print(data, file=sys.stderr)
            raise


@dataclass_json
@dataclasses.dataclass
class JanusHandleResponse(JanusResponseBase):
    session_id: int
    handle_id: int
    info: JanusHandleResponseInfo


@dataclass_json
@dataclasses.dataclass
class JanusLoop:
    id: int
    handles: int


@dataclass_json
@dataclasses.dataclass
class JanusLoopResponse(JanusResponseBase):
    loops: List[JanusLoop]


@dataclass_json
@dataclasses.dataclass
class JanusListSessionsResponse(JanusResponseBase):
    sessions: List[int]


@dataclass_json
@dataclasses.dataclass
class JanusListHandlesResponse(JanusResponseBase):
    handles: List[int]


def with_parsing(cls: JanusResponseBase):
    def decorator(function):
        def wrapper(*args, **kwargs):
            result = function(*args, **kwargs)
            return cls.from_resp(result)
        return wrapper
    return decorator


def _request(key: str, data: dict):
    data = {
        "janus": key,
        "transaction": "test",
        "admin_secret": ADMIN_SECRET,
        **data
    }
    return requests.post(URL, json=data)


def get_loops_info():
    return _request("loops_info", dict())


@with_parsing(JanusListSessionsResponse)
def get_list_sessions():
    return _request("list_sessions", dict())


@with_parsing(JanusListHandlesResponse)
def get_list_handles(session_id):
    return _request("list_handles", {"session_id": session_id})


def _request_handle_info(key: str, session_id: int, handle_id: int):
    return _request(key, {"session_id": session_id, "handle_id": handle_id})


@with_parsing(JanusHandleResponse)
def get_handle_info(session_id: int, handle_id: int):
    return _request_handle_info("handle_info", session_id, handle_id)


def start_pcap(session_id: int, handle_id: int):
    return _request(
        "start_pcap",
        {"session_id": session_id, "handle_id": handle_id, "folder": "/home/janus", "filename": "unencrypt.pcap"}
    )


def stop_pcap(session_id: int, handle_id: int):
    return _request_handle_info("stop_pcap", session_id, handle_id)


def iter_session_handle_tuples(sessions: List[int]):
    for sid in sessions:
        resp = get_list_handles(sid)
        yield from ((sid, hid) for hid in resp.handles)


def iter_all_session_handle_tuples():
    resp = get_list_sessions()
    yield from iter_session_handle_tuples(resp.sessions)


def get_one_session_handle():
    return next(iter_all_session_handle_tuples())


def get_packet_and_nack(tuples):
    nacks = 0
    packets = 0

    for sid, hid in tuples:
        data = get_handle_info(sid, hid).json()
        print(JanusHandleResponse.from_dict(data))

        exit(1)
        info = data["info"]["webrtc"]["media"]["v"]
        nacks += info["stats"]["in"]["nacks"]
        packets += info["stats"]["out"]["packets"]

    return packets, nacks


def video_stats(info: JanusHandleResponseInfo):
    return info.webrtc.media.v.stats


def video_rtcp(info: JanusHandleResponseInfo):
    return info.webrtc.media.v.rtcp.main


def nack_count(info: JanusHandleResponseInfo):
    return video_stats(info).i.nacks


def packet_count(info: JanusHandleResponseInfo):
    return video_stats(info).o.packets


def jitter_remote(info: JanusHandleResponseInfo):
    return video_rtcp(info).jitter_remote


def lost_remote(info: JanusHandleResponseInfo):
    return video_rtcp(info).lost_by_remote


def make_summary(info: JanusHandleResponseInfo):
    return [
        packet_count(info),
        nack_count(info) or 0,  # for nack disabled
        lost_remote(info),
        jitter_remote(info),
    ]


def make_summary_array(infos: List[JanusHandleResponseInfo]):
    return np.array([make_summary(info) for info in infos])


def print_array(key: str, arr):
    print(f"{key}: {arr.mean()} (+-{arr.std()})")


def measure_throughput(n: int = 10, delta: int = 1):
    assert n > 0, "n should be positive integer"

    res = list()
    with open("/sys/class/net/lo/statistics/tx_bytes") as file:
        for _ in range(n):
            file.seek(0)
            b1 = int(file.read())
            t1 = time.perf_counter()

            time.sleep(delta)

            file.seek(0)
            b2 = int(file.read())
            t2 = time.perf_counter()

            res.append(8 * (b2 - b1) / (t2 - t1))

    return np.array(res)


def get_tuples_from_sessions(sessions: List[int], verbose: bool = False):
    return [
        t for t in tqdm.tqdm(
            iter_session_handle_tuples(sessions), "handle",
            total=len(sessions), disable=not verbose,
        )
    ]



def try_handle_info(session_id: int, handle_id: int):
    try:
        return get_handle_info(session_id, handle_id).info
    except KeyError as error:
        print(repr(error), file=sys.stderr)
        return None


def sample_sessions(sessions: List[int], sample: int, is_all: int):
    if is_all:
        return sessions
    
    sample_count = min(len(sessions), sample)
    return random.sample(sessions, k=sample_count)


def parse_args():
    base_parser = argparse.ArgumentParser(description="The parent parser", add_help=False)
    base_parser.add_argument("command", choices=["check", "measure", "count"])
    base_parser.add_argument("-n", "--sample", dest="sample", default=100, type=int)
    base_parser.add_argument("-a", "--all", dest="all", action="store_true")
    base_parser.add_argument("-v", "--verbose", dest="v", action="store_true")
    base_parser.add_argument("--json", action="store_true")

    return base_parser.parse_args()


def check_count(args: argparse.Namespace):
    resp = get_list_sessions()
    print(len(resp.sessions))


def check(args: argparse.Namespace):
    resp = get_list_sessions()
    sessions = sample_sessions(resp.sessions, args.sample, args.all)
    tuples = get_tuples_from_sessions(sessions, args.v)
    
    total = len(tuples)
    error_counter = dict()

    for session_id, handle_id in tuples:
        try:
            get_handle_info(session_id, handle_id)
        except KeyError as error:
            key = str(error)
            error_counter[key] = error_counter.get(key, 0) + 1

    errors = sum(error_counter.values())
    normal = total - errors

    print(f"total : {total}")
    print(f"normal: {normal}")
    print(f"error : {errors}")
    for key, count in error_counter.items():
        print(f"- No {key[1: -1]}: {count}")

    sys.exit(1 if errors > 0 else 0)


def measure(args: argparse.Namespace):
    resp = get_list_sessions()
    print(f"Sess: {len(resp.sessions)}")

    sessions = sample_sessions(resp.sessions, args.sample, args.all)
    print(f"Samp: {len(sessions)}")

    tuples = get_tuples_from_sessions(sessions, args.v)

    try_info1s = [try_handle_info(*t) for t in tqdm.tqdm(tuples, "info1", disable=not args.v)]
    info1s = [info for info in try_info1s if info is not None]
    print(f"Norm: {len(info1s)}")

    thr_arr = measure_throughput()
    print_array("Thro", thr_arr)

    if not try_info1s:
        return

    info2s = [
        get_handle_info(info.session_id, info.handle_id).info
        for info in tqdm.tqdm(info1s, "info2", disable=not args.v)
    ]

    arr1 = make_summary_array(info1s)
    arr2 = make_summary_array(info2s)

    delta = arr2 - arr1
    packets = delta[:, 0]
    nacks = delta[:, 1]
    losts = delta[:, 2]
    nack_rates = nacks / packets
    lost_rates = losts / packets
    jitters = arr2[:, 3]

    print_array("Nack", nack_rates)
    print_array("Lost", lost_rates)
    print_array("Jitt", jitters)


def main():
    args = parse_args()

    if args.command == "check":
        check(args)
    elif args.command == "measure":
        measure(args)
    elif args.command == "count":
        check_count(args)
    else:
        raise NotImplementedError


if __name__ == "__main__":
    main()

