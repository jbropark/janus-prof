import random
import subprocess


COMMANDS = ["./send_mul1", "./send_mul2"]


def main():
    results = {cmd: list() for cmd in COMMANDS}

    for idx in range(1000):
        command = random.choice(COMMANDS)
        print(f"Run {idx}: {command}")
        res = subprocess.check_output([command])
        results[command].append(res)

    for cmd, res in results.items():
        print(cmd, len(res), sum(map(float, res)) / len(res))
    

if __name__ == "__main__":
    main()

