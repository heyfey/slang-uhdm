// r10buvm14 arm a1 — THE DIMENSION AXIS of a BUILT-IN METHOD CALL's RECEIVER.
//
// One golden, one file, every cell written beside its own control.  The
// question each cell answers is: how many `bit_select` elements does the
// hier_path carry, what is each one's vpiName and vpiFullName, and where does
// its index hang?
//
// Cells L1..L3 are the AXIS (0-D / 1-D / 2-D receiver of the SAME method on the
// SAME kind of array); L4..L6 vary the METHOD; L7 the DIMENSION COUNT to 3;
// L8 a MID step; L9/L10 the INDEX KIND; R1..R4 are REFUSAL controls that must
// NOT move; S1/S2 are STATEMENT position, a different arm entirely.
package p14;

  class h14;
    int mm[string][string][string];
    string s1[string];
  endclass

  class c14;
    int m0[string];
    int m1[string][string];
    int m2[string][string][string];
    int m3[string][string][string][string];
    int q2[int][int][int];
    int qn[int][int][int];
    h14 hh;
    int idxarr[int];

    function int f14(string a, string b, string c, string d, int i, int j);
      int r = 0;
      if (m0.exists(a)) r++;                 // L1  0-D  -> ref_obj + call
      if (m1[a].exists(b)) r++;              // L2  1-D  -> 1 bit_select
      if (m2[a][b].exists(c)) r++;           // L3  2-D  -> 2 bit_selects  <== HEAD
      r += m2[a][b].num();                   // L4  2-D, .num
      r += m2[a][b].size();                  // L5  2-D, .size
      if (m2[a][b].first(c)) r++;            // L6  2-D, .first
      if (m3[a][b][c].exists(d)) r++;        // L7  3-D  -> 3 bit_selects
      if (hh.mm[a][b].exists(c)) r++;        // L8  MID step, 2-D
      r += q2[1][2].size();                  // L9  LITERAL indices, 2-D
      r += qn[i][j].size();                  // L10 VARIABLE int indices, 2-D
      r += m1[hh.s1[a]].size();              // R1  a DOT inside the index
      r += qn[idxarr[i]].size();             // R2  a NESTED bracket in the index
      r += m0.size();                        // R3  no index at all
      r += m1[a].num();                      // R4  1-D control beside L4
      return r;
    endfunction

    task t14(string a, string b, string c);
      m2[a][b].delete(c);                    // S1  STATEMENT position, 2-D
      m1[a].delete(b);                       // S2  STATEMENT position, 1-D
    endtask
  endclass

endpackage

module m14;
  import p14::*;
  c14 o14;
  int rr;
  initial begin
    o14 = new();
    rr = o14.f14("a", "b", "c", "d", 1, 2);
  end
endmodule
