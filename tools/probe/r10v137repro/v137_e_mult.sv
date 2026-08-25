// r10v137 arm E — REPEATED HOMES AND MULTIPLE INSTANCES.
// One parameterised module carrying an admitted MODULE-level array and a
// dotted inner loop list, instantiated ONE, TWO and THREE times, plus a
// package class used from each instance and a PROGRAM home for contrast.
// MEASUREMENT ONLY.
package weave137;
  typedef class Thread137;
  typedef struct { bit picks137[Thread137]; int ends137[string]; } warp137_s;
  class Thread137;
    bit picks137[Thread137];
    int ends137[string];
  endclass
  class Loom137;
    function int spin137(ref warp137_s fwp137[Thread137]);
      int n137;
      foreach (fwp137[f1]) foreach (f1.picks137[f2]) n137++;
      foreach (fwp137[f3]) foreach (f3.ends137[f4]) n137++;
      return n137;
    endfunction
  endclass
endpackage

module cloth137 #(parameter int W137 = 1) ();
  weave137::warp137_s mwp137[weave137::Thread137];
  weave137::Thread137 mtd137[weave137::Thread137];
  weave137::Loom137   lm137;
  int n137;
  initial begin
    lm137 = new();
    foreach (mwp137[g1]) foreach (g1.picks137[g2]) n137++;
    foreach (mtd137[g3]) foreach (g3.ends137[g4]) n137++;
    n137 += lm137.spin137(mwp137);
  end
endmodule

program bolt137;
  weave137::warp137_s pwp137[weave137::Thread137];
  int n137;
  initial begin
    foreach (pwp137[h1]) foreach (h1.picks137[h2]) n137++;
  end
endprogram

module tope137;
  cloth137 #(1) c1_137();
  cloth137 #(2) c2_137();
  cloth137 #(3) c3_137();
  bolt137 b137();
endmodule
