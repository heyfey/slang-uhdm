// r11v81 adversarial arm v9 — a `parameter` (not `localparam`) hop in a
// PACKAGE, and an untyped hop whose store is a DECLARED-type name.
package v9p;
  parameter  PP = 16'h5;
  parameter  PQ = 16'd5;
  localparam int TI = 5;
  localparam UT = TI;
  localparam byte TB = 8'd5;
  localparam UB = TB;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] p; logic [23:0] q; logic [23:0] u;
    logic [23:0] v;
  } t9;
  localparam t9 G = '{bail: 8'hxA, p: PP, q: PQ, u: UT, v: UB};
endpackage
module v9_kwd81 #(parameter v9p::t9 CG = v9p::G) (output logic [23:0] o);
  assign o = CG.p ^ CG.q ^ CG.u ^ CG.v;
endmodule
