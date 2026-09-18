# SPDX-FileCopyrightText: 2026 Vitalik Makhnev
# SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import unittest

import normalize


class NormalizeTests(unittest.TestCase):
    def test_normalizes_merges_and_sorts_by_total_count(self):
        records = [
            ("Cafe\u0301", 4),
            ("CAFÉ", 6),
            ("world", 8),
            ("CAN’T", 3),
        ]

        self.assertEqual(
            normalize.normalize_records(records, "en"),
            ["café", "world", "can't"],
        )

    def test_filters_tokens_without_letters_or_with_unsafe_scalars(self):
        records = [
            ("123", 100),
            ("abc123", 10),
            ("bad\ufffd", 9),
            ("private\ue000", 8),
            ("line\nfeed", 7),
        ]

        self.assertEqual(normalize.normalize_records(records, "en"), ["abc123"])

    def test_retains_only_verified_single_character_words(self):
        records = [("z", 100), ("I", 90), ("a", 80)]

        self.assertEqual(normalize.normalize_records(records, "en"), ["i", "a"])

    def test_retains_russian_single_character_word_needed_for_conversion(self):
        records = [("я", 100), ("ф", 90), ("привет", 80)]

        self.assertEqual(normalize.normalize_records(records, "ru"), ["я", "привет"])

    def test_uses_turkish_lowercase_rules(self):
        records = [("I", 10), ("İ", 9), ("O", 8)]

        self.assertEqual(normalize.normalize_records(records, "tr"), ["o"])


if __name__ == "__main__":
    unittest.main()
