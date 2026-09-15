// v11u42 arm v3 — SCOPE faces: which declaration folds, which keeps its name.
package pv3;
  localparam int unsigned LP = 8;
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
endpackage
package pv3b;
  import pv3::*;
  localparam int unsigned RELAY = pv3::LP;   // a pkg param initialised from another pkg
endpackage

interface iv3 #(parameter int unsigned IPP = 6) ();
  pv3::s_t v;
endinterface

module sub #(parameter int unsigned SPP = 7) (input logic [19:0] w20, output logic [7:0] so);
  pv3::s_t v;
  assign v = w20;
  assign so[0] = v.m[SPP-1];             // c01 module parameter (OVERRIDDEN per instance)
  assign so[1] = v.m[pv3::LP-1];         // c02 pkg param inside an instantiated child
endmodule

module v3 (input logic [19:0] w20, output logic [63:0] o);
  import pv3::LP;                        // EXPLICIT single import
  pv3::s_t v;
  assign v = w20;
  assign o[0] = v.m[LP-1];               // c03 explicitly imported, unqualified
  assign o[1] = v.m[pv3b::RELAY-1];      // c04 pkg param initialised from another pkg param
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk
      localparam int unsigned GLP = gi + 4;   // GENERATE-scope localparam
      assign o[2+gi] = v.m[GLP-1];       // c05/c06 generate-scope localparam
      assign o[4+gi] = v.m[pv3::LP-1-gi];// c07/c08 pkg param + genvar
    end
  endgenerate
  iv3 u_if ();
  assign u_if.v = w20;
  assign o[6] = u_if.v.m[pv3::LP-1];     // c09 through an interface instance
  sub #(.SPP(9)) u_s0 (.w20(w20), .so(o[15:8]));   // c10 instance 1
  sub #(.SPP(5)) u_s1 (.w20(w20), .so(o[23:16]));  // c11 instance 2
  sub          u_s2 (.w20(w20), .so(o[31:24]));    // c12 instance 3 (default)
endmodule
