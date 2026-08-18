// v9 — MULTI-PARAMETERIZED def x port form x home.  With two distinct tuples
// the `multiParamIface` keep-all path is live, so the new gate is the ONLY
// thing that can drop -- the R-N1 residue's home.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module pchild (ifc p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [7:0] o);
  ifc #(16, 3) a ();
  ifc #(8, 2)  b ();          // second distinct tuple -> multi-parameterized
  child  u1 (.p(a), .o(o[0]));
  child  u2 (.p(b), .o(o[1]));
  pchild u3 (.p(a), .o(o[2]));
  pchild u4 (.p(b), .o(o[3]));
  if (1) begin : g
    child  u5 (.p(a), .o(o[4]));
    pchild u6 (.p(a), .o(o[5]));
    ifc #(16, 3) c ();
    child  u7 (.p(c), .o(o[6]));
    pchild u8 (.p(c), .o(o[7]));
  end
endmodule
