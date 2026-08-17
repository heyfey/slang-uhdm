// v6 — the DEF-view / share axis.  Every earlier arm's member-Lhs cast lives in
// a module that HAS a parameter.  When the module has NO parameter the def view
// can already carry a folded constant, and the elab view may SHARE it — so the
// patch's "keep the operation" could be a no-op, or could fight the share.
// Also crossed: the struct declared explicitly as a `wire` vs a plain (var)
// declaration, and an internal struct in a module with no parameters.
package v6p;
  parameter int unsigned SZW = 4;
  typedef enum logic [2:0] { OP_A = 3'h0, OP_B = 3'h1 } op_e;
  typedef struct packed { logic [6:0] rsvd; logic en; } user_t;
  typedef struct packed {
    logic       valid;
    op_e        opcode;
    logic [3:0] c1;
    logic [3:0] c2;
    logic [3:0] c3;
    user_t      user;
  } h2d_t;
endpackage

// NO parameters at all — the def view can fold on its own
module v6_noparam (
  input  logic       req,
  output v6p::h2d_t  tl,
  output logic [3:0] n1
);
  localparam int unsigned LPL = $clog2(32/8);   // from LITERALS only
  wire v6p::h2d_t w;                            // explicit WIRE struct
  v6p::h2d_t      v;                            // plain (var) struct

  assign tl.c1 = v6p::SZW'(LPL);
  assign w.c1  = v6p::SZW'(LPL);
  assign v.c1  = v6p::SZW'(LPL);
  assign n1    = v6p::SZW'(LPL) | w.c1 | v.c1;
endmodule

// the SAME module body, instantiated twice, to cross def-share with two views
module v6_earl51 (
  input  logic       req,
  output v6p::h2d_t  a_tl,
  output v6p::h2d_t  b_tl,
  output logic [3:0] a_n1,
  output logic [3:0] b_n1
);
  v6_noparam u_a (.req(req), .tl(a_tl), .n1(a_n1));
  v6_noparam u_b (.req(req), .tl(b_tl), .n1(b_n1));
endmodule
