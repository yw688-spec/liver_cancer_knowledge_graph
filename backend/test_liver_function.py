# -*- coding: utf-8 -*-
"""
Unit tests for the Python lab-unit conversion helpers in kb.py.

The Child-Pugh / ALBI scoring itself lives in Prolog and is covered by
prolog/tests.pl (the `scoring` group). Here we only pin the unit conversions,
which run without SWI-Prolog.

Run:
    cd backend && python -m unittest test_liver_function -v
"""
import unittest

import kb


class UnitConversionTest(unittest.TestCase):
    def test_bilirubin_mg_dl_to_umol(self):
        self.assertAlmostEqual(kb._bilirubin_umol(2.0, "mg/dL"), 34.2, places=3)

    def test_bilirubin_umol_passthrough(self):
        self.assertEqual(kb._bilirubin_umol(34.2, "umol/L"), 34.2)

    def test_albumin_g_dl_to_g_l(self):
        self.assertEqual(kb._albumin_gl(3.5, "g/dL"), 35.0)

    def test_albumin_g_l_passthrough(self):
        self.assertEqual(kb._albumin_gl(35.0, "g/L"), 35.0)


if __name__ == "__main__":
    unittest.main()
