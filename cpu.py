import argparse


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("pid", type=int)
    return parser.parse_args()


def main():
    args = parse_args()

    args.pid

    print(args.pid)


if __name__ == "__main__":
    main()

