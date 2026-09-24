// VERIFIER arm v3 — the SYSTEM-CALL over-fire probe: system functions the
// implementer's a2 never wrote, incl. REAL-argument and REAL-return shapes
// (a2 m09 is the only real-arg cell and it is NOT =golden — see README.verifier).
package p3v;
  class c3v;
    int    t01 = $countones(8'hff);
    int    t02 = $onehot(8'h01);
    real   t03 = $ln(2.0);
    real   t04 = $pow(2.0, 3.0);
    int    t05 = $signed(3);
    int    t06 = $unsigned(3);
    string t07 = $psprintf("%0d", 7);
    int    t08 = $size(int);
    int    t09 = $high(8'hff);
    int    t10 = $isunknown(1'b1);
    real   t11 = $realtime;
    int    t12 = $stime;
  endclass
endpackage
