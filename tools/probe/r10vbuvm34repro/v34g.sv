// r10vbuvm34repro/v34g.sv — VERIFIER ARM G: does an INTERFACE / PROGRAM home
// resolve the loop variable at all?  r10buvm34's residue R1 says "interface
// and program resolve NOTHING in golden"; v34b measured an INSTANTIATED
// interface resolving one.  This arm holds the text constant and varies ONLY
// the INSTANTIATION.  MEASUREMENT ONLY.
package pg34;
  class cg34;
    typedef cg34 this_type;
    static int gq34 [$];
    static int ga34 [string];
  endclass
endpackage

interface ifI34;            // INSTANTIATED below
  import pg34::*;
  string iarr34 [$];
  function void f34();
    int r;
    foreach (cg34::gq34[i]) r = i;      // I1 scoped
    foreach (iarr34[i])     r = i;      // I2 bare
  endfunction
endinterface

interface ifU34;            // NEVER instantiated
  import pg34::*;
  string uarr34 [$];
  function void f34();
    int r;
    foreach (cg34::gq34[i]) r = i;      // U1 scoped
    foreach (uarr34[i])     r = i;      // U2 bare
  endfunction
endinterface

program pgI34;              // INSTANTIATED below
  import pg34::*;
  string parr34 [$];
  initial begin
    int r;
    foreach (cg34::gq34[i]) r = i;      // PI1 scoped
    foreach (parr34[i])     r = i;      // PI2 bare
  end
endprogram

program pgU34;              // NEVER instantiated
  import pg34::*;
  string qarr34 [$];
  initial begin
    int r;
    foreach (cg34::gq34[i]) r = i;      // PU1 scoped
    foreach (qarr34[i])     r = i;      // PU2 bare
  end
endprogram

module topg34;
  ifI34 ii();
  pgI34 pi();
endmodule
