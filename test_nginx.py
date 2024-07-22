import subprocess
import argparse


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--secure", action="store_true")
    parser.add_argument("--host", default="172.20.0.3")
    parser.add_argument("--file", default="dummy.bin")
    parser.add_argument("--repeat", type=int, default=1000)
    parser.add_argument("--worker", type=int, default=500)
    return parser.parse_args()


def main():
    args = parse_args()

    url = f"{'https' if args.secure else 'http'}://{args.host}/{args.file}?[1-{args.repeat}]"
    command = ["curl", "-s", "-k", url]

    print(f"url     : {url}")
    print(f"worker  : {args.worker}")
    print(f"command : {' '.join(command)}")

    ps = [subprocess.Popen(command, stdout=subprocess.DEVNULL) for _ in range(args.worker)]
    for p in ps:
        p.wait()


if __name__ == "__main__":
    main()

