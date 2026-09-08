// v214 arm 7 — A PARAMETERIZED CLASS with out-of-body methods reading the
// package's own parameters, plus a specialization.  The clone driver walks
// GenericClassDef default specializations; this arm asks whether the law fires
// there and whether golden agrees.
package pv7;
  parameter int ga7 = 21;
  parameter gb7 = ga7;
  function automatic int gsink7(int a, int b); return a + b; endfunction
  class G7 #(int P7 = 2);
    extern function int g_rd7();
  endclass
  function int G7::g_rd7();
    return gsink7(ga7, gb7) + P7;
  endfunction
endpackage
module topv7;
  pv7::G7 #(2) g2 = new();
  pv7::G7 #(5) g5 = new();
  int x, y;
  initial begin x = g2.g_rd7(); y = g5.g_rd7(); end
endmodule
