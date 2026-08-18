// § genvarIdxFoldRerender14 ARM pc2 — the BARE-PARAMETER index.  Golden gives
// it the parameter's OWN declaration constant (r10rgg11 § genLpPortConnValue11,
// vpiSize 32 for an `int`), a DIFFERENT law this pass does not take, so the
// gate ABSTAINS and the cell must be BYTE-IDENTICAL between the two binaries.
interface sif;
  logic v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s);
  wire w;
  assign w = s.v;
endmodule
module top #(parameter int P = 5);
  sif sarr [0:63] ();
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    ileaf ua (.s (sarr[P]));
    ileaf ub (.s (sarr[7]));
  end
endmodule
