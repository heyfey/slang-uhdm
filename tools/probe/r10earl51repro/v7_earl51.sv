// v7 — GENERATE and INTERFACE views.  A member-Lhs cast inside a generate-for
// body, inside an instantiated INTERFACE, and reached through an instance ARRAY.
package v7p;
  parameter int unsigned SZW = 4;
  typedef enum logic [2:0] { OP_A = 3'h0, OP_B = 3'h1 } op_e;
  typedef struct packed { logic [6:0] rsvd; logic en; } user_t;
  typedef struct packed {
    logic       valid;
    op_e        opcode;
    logic [3:0] c1;
    logic [3:0] c2;
    user_t      user;
  } h2d_t;
endpackage

interface v7_if #(parameter int DW = 32) ();
  localparam int unsigned LPD = $clog2(DW/8);
  v7p::h2d_t tl;
  assign tl.c1 = v7p::SZW'(LPD);          // member-Lhs cast INSIDE an interface
endinterface

module v7_leaf #(parameter int DW = 32) (
  output v7p::h2d_t tl
);
  localparam int unsigned LPD = $clog2(DW/8);
  assign tl.c1 = v7p::SZW'(LPD);
  assign tl.c2 = v7p::SZW'(2);
endmodule

module v7_earl51 (
  input  logic       req,
  output v7p::h2d_t  o [0:1],
  output logic [3:0] n1
);
  localparam int unsigned LP2 = 2;
  v7p::h2d_t gs [0:1];

  v7_if #(.DW(32)) u_if ();               // INSTANTIATED interface
  v7_leaf #(.DW(32)) u_arr [0:1] ();      // instance ARRAY

  for (genvar gi = 0; gi < 2; gi++) begin : g
    v7p::h2d_t loc;
    assign loc.c1 = v7p::SZW'(LP2 + gi);  // member Lhs, cast over a GENVAR
    assign loc.c2 = v7p::SZW'(LP2);       // member Lhs, cast over a localparam
    assign gs[gi] = loc;
  end

  assign o[0] = gs[0];
  assign o[1] = gs[1];
  assign n1   = u_if.tl.c1;
endmodule
