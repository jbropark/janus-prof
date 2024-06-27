import subprocess


COMMAND = ["curl", "http://127.0.0.1/dummy.bin"]


def main():
    ps = [subprocess.Popen(COMMAND, stdout=subprocess.DEVNULL) for _ in range(500)]
    for p in ps:
        p.wait()


if __name__ == "__main__":
    main()

