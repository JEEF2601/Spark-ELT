from __future__ import annotations

import argparse
import sys
from pathlib import Path

SPARK_JOBS_ROOT = Path(__file__).resolve().parents[1]
if str(SPARK_JOBS_ROOT) not in sys.path:
    sys.path.insert(0, str(SPARK_JOBS_ROOT))

from common.spark_session import build_spark_session


def run(date: str | None = None) -> None:
    spark = build_spark_session("daily_aggregation")
    print(f"daily_aggregation base lista. date={date}")
    spark.stop()


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--date", required=False)
    return parser.parse_args()


if __name__ == "__main__":
    args = _parse_args()
    run(date=args.date)
