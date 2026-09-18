#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Vitalik Makhnev
# SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import argparse
from collections import defaultdict
from pathlib import Path
import tempfile
import unicodedata


LANGUAGES = (
    "af bg br bs ca cs da de el en eo es et eu fi fr gl hr hu hy id is it ka "
    "kk lt lv mk ms nl no pl pt pt_br ro ru sk sl sq sr sv tl tr uk"
).split()
FULL_LIST_LANGUAGES = {"af", "br", "eo", "hy", "kk", "tl"}

# Only standalone words verified for the corresponding language are retained.
# Every other one-character corpus entry is treated as subtitle noise.
SINGLE_CHARACTER_WORDS = {
    "af": {"u"},
    "bg": {"а", "в", "е", "и", "о", "с", "у", "я", "ѝ"},
    "br": {"a", "e", "o"},
    "bs": {"a", "i", "k", "o", "s", "u"},
    "ca": {"a", "i", "o"},
    "cs": {"a", "i", "k", "o", "s", "u", "v", "z"},
    "da": {"i", "å"},
    "de": set(),
    "el": {"ή", "η", "ο"},
    "en": {"a", "i"},
    "eo": set(),
    "es": {"a", "e", "o", "u", "y"},
    "et": set(),
    "eu": set(),
    "fi": set(),
    "fr": {"a", "y", "à"},
    "gl": {"a", "e", "o", "á", "é", "ó"},
    "hr": {"a", "i", "k", "o", "s", "u"},
    "hu": {"a", "ő"},
    "hy": {"է", "ի", "և"},
    "id": set(),
    "is": {"á", "í"},
    "it": {"a", "e", "i", "o", "è"},
    "ka": set(),
    "kk": set(),
    "lt": {"o", "į"},
    "lv": set(),
    "mk": {"а", "е", "и"},
    "ms": set(),
    "nl": {"u"},
    "no": {"i", "å"},
    "pl": {"a", "i", "o", "u", "w", "z"},
    "pt": {"a", "e", "o", "à", "é"},
    "pt_br": {"a", "e", "o", "à", "é"},
    "ro": {"a", "e", "i", "o"},
    "ru": {"а", "в", "и", "к", "о", "с", "у", "я"},
    "sk": {"a", "i", "k", "o", "s", "u", "v", "z"},
    "sl": {"a", "k", "o", "s", "v", "z"},
    "sq": {"e", "i", "u"},
    "sr": {"a", "i", "k", "o", "s", "u", "а", "и", "к", "о", "с", "у"},
    "sv": {"i", "å"},
    "tl": {"o"},
    "tr": {"o"},
    "uk": {"а", "в", "з", "і", "й", "о", "у", "я"},
}

APOSTROPHES = dict.fromkeys(map(ord, "’‘ʼ"), "'")
DASHES = dict.fromkeys(map(ord, "‐‑‒–—―"), "-")
CANONICAL_TRANSLATION = APOSTROPHES | DASHES


def normalize_word(word: str, language_code: str) -> str:
    word = unicodedata.normalize("NFC", word).translate(CANONICAL_TRANSLATION)
    if language_code == "tr":
        word = word.replace("I", "ı").replace("İ", "i")
    return unicodedata.normalize("NFC", word.lower())


def is_valid(word: str) -> bool:
    if "\ufffd" in word:
        return False
    categories = [unicodedata.category(character) for character in word]
    if any(category.startswith("C") for category in categories):
        return False
    return any(category.startswith("L") for category in categories)


def normalize_records(records: list[tuple[str, int]], language_code: str) -> list[str]:
    counts: defaultdict[str, int] = defaultdict(int)
    allowed_single_characters = SINGLE_CHARACTER_WORDS[language_code]
    for raw_word, count in records:
        word = normalize_word(raw_word, language_code)
        if not is_valid(word):
            continue
        if len(word) == 1 and word not in allowed_single_characters:
            continue
        counts[word] += count
    return [
        word
        for word, _ in sorted(counts.items(), key=lambda item: (-item[1], item[0]))
    ]


def read_records(path: Path) -> list[tuple[str, int]]:
    records: list[tuple[str, int]] = []
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        try:
            word, raw_count = line.rsplit(maxsplit=1)
            records.append((word, int(raw_count)))
        except ValueError as error:
            raise ValueError(f"Invalid record at {path}:{line_number}") from error
    return records


def source_path(source_directory: Path, language_code: str) -> Path:
    suffix = "full" if language_code in FULL_LIST_LANGUAGES else "50k"
    filename = f"{language_code}_{suffix}.txt"
    flat = source_directory / filename
    nested = source_directory / language_code / filename
    if flat.is_file():
        return flat
    if nested.is_file():
        return nested
    raise FileNotFoundError(f"Missing source list for {language_code}: {filename}")


def generate(source_directory: Path, output_directory: Path) -> None:
    output_directory.mkdir(parents=True, exist_ok=True)
    for language_code in LANGUAGES:
        words = normalize_records(
            read_records(source_path(source_directory, language_code)),
            language_code,
        )
        (output_directory / f"{language_code}.txt").write_text(
            "\n".join(words) + "\n",
            encoding="utf-8",
        )


def verify(source_directory: Path, output_directory: Path) -> bool:
    with tempfile.TemporaryDirectory() as temporary_directory:
        generated_directory = Path(temporary_directory)
        generate(source_directory, generated_directory)
        for language_code in LANGUAGES:
            filename = f"{language_code}.txt"
            expected = generated_directory / filename
            actual = output_directory / filename
            if not actual.is_file() or actual.read_bytes() != expected.read_bytes():
                print(f"Generated resource differs: {filename}")
                return False
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description="Normalize FrequencyWords 2018 lists")
    parser.add_argument("--source-dir", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--verify", action="store_true")
    arguments = parser.parse_args()

    if arguments.verify:
        return 0 if verify(arguments.source_dir, arguments.output_dir) else 1
    generate(arguments.source_dir, arguments.output_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
