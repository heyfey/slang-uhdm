// v55 adversarial arm 3 — OTHER FOLD ORIGINS that must be untouched:
// port-connection (HighConn) replication folds at depths 0..3, a CAST fold,
// a NET-DECL-ASSIGN fold, an `int`-declared fold (the earl52 int-only arm),
// an INTERFACE-scoped width-1 fold, and a FUNCTION-local one.
// MEASURED (both views, both binaries): TO-GOLDEN 4 / AWAY-GOLDEN 0 /
// STILL-WRONG 0.  The width-1 fold lands on golden at conn/param depths 0, 1
// AND 2 of a 3-deep override+HighConn chain, and inside an INTERFACE.  The
// earl52 int-only sibling arm (IA/IB/IC) is byte-unchanged and still wrong the
// SAME way it was: golden's loc-less int_typespec carries VpiValue UINT:1 and
// ours carries none (R2) — cmp-INVISIBLE, verified against
// UHDM int_typespec::Compare, which reads Cast_to_expr, VpiSigned and Ranges
// only.  The CAST fold (CA) and the function-local param are untouched; the
// function-local one is also UNPAIRED because our fullname is `work@d2_v55.g.FX`
// where golden's is `work@v3_v55.u_d2.g.FX` (V3, pre-existing).
interface if3_55;
  localparam logic [0:0] IW1 = {1{1'b1}};
  logic sig;
endinterface

module v3_v55(input logic ext);
  if3_55 u_if ();
  d0_v55 u_d0 (.o(), .ext(ext));
  d1_v55 u_d1 (.o(), .ext(ext));
  d2_v55 u_d2 (.o(), .ext(ext));
  assign u_if.sig = ext;
endmodule

// depth chain: a width-1 replication fold handed DOWN through 3 levels of
// port/parameter connection
module d0_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  d0a_v55 #(.P(X)) u_a (.a({1{1'b1}}), .z(o), .ext(ext));
endmodule
module d0a_v55 #(parameter logic [0:0] P = 1'b0)
                (input logic a, output logic z, input logic ext);
  localparam logic [0:0] Y = {1{P}};
  d0b_v55 #(.Q(Y)) u_b (.a({1{a}}), .z(z), .ext(ext));
endmodule
module d0b_v55 #(parameter logic [0:0] Q = 1'b0)
                (input logic a, output logic z, input logic ext);
  localparam logic [0:0] Z = {1{Q}};
  d0c_v55 u_c (.a({1{Z}}), .z(z));
endmodule
module d0c_v55 (input logic a, output logic z); assign z = a; endmodule

// a CAST fold, a NET-DECL-ASSIGN fold and the int-declared arm (earl52)
module d1_v55 (output logic o, input logic ext);
  localparam logic [0:0] CA = logic'({1{1'b1}});
  localparam logic [0:0] CB = 1'({1{1'b1}});
  localparam int         IA = {1{1'b1}};
  localparam int         IB = {32{1'b1}};
  localparam integer     IC = {1{1'b1}};
  wire [0:0] nd = {1{1'b1}};
  assign o = ext ^ nd[0];
endmodule

// a FUNCTION-local width-1 fold and one read through the interface
module d2_v55 (output logic o, input logic ext);
  function automatic logic g(input logic a);
    localparam logic [0:0] FX = {1{1'b1}};
    return a ^ FX[0];
  endfunction
  assign o = g(ext);
endmodule
