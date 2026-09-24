// § genvarIdxFoldRerender14 POSITIVE CONTROL — the law in miniature: an
// interface-instance-array port actual and a net-array one, both indexed by a
// genvar-dependent expression, in an unrolled generate-for body.  Golden folds
// each to ONE constant whose decompile is RE-RENDERED from the value, whose
// vpiConstType follows ExprEval's add/mult signedness, and whose span is the
// top operation's LEFT OPERAND.
interface sif;
  logic v;
  modport mp (input v);
endinterface

module ileaf (sif.mp s);
  wire w;
  assign w = s.v;
endmodule

module nleaf (input logic p);
  wire w;
  assign w = p;
endmodule

module top (input logic [63:0] arr);
  sif sarr [0:63] ();
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    ileaf ua (.s (sarr[10+i]));
    ileaf ub (.s (sarr[2+4*i]));
    nleaf uc (.p (arr[10+i]));
    nleaf ud (.p (arr[2+4*i]));
  end
endmodule
