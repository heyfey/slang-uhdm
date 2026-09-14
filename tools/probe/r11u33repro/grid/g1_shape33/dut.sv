// r11u33 grid arm g1_shape33 — THE BOUND SHAPE at a module-body declaration.
//
// Every cell is a module-body VARIABLE.  The packed dim (`p_*`) and the
// unpacked RANGE dim (`u_*`) carry the SAME written bound, so the two sites
// can be read side by side for one shape.  What is being read out of golden
// per cell is the LEFT bound constant's vpiSize / vpiConstType / value tag.
module g1_shape33 #(
    parameter int unsigned NU = 5,     // int unsigned -> stored Value 32/UINT
    parameter int          NS = 6,     // int (signed) -> stored Value 32/INT?
    parameter              NX = 7,     // UNTYPED
    parameter byte         NB = 9,     // 8 bits
    parameter logic [7:0]  NL = 11,    // 8 bits, logic
    parameter int unsigned MU = 3      // second int unsigned, for A+B
) (
    input logic clk
);
  // --- bare identifier bounds ------------------------------------------
  logic [NU:0] p_nu;   logic q_nu [NU:1];
  logic [NS:0] p_ns;   logic q_ns [NS:1];
  logic [NX:0] p_nx;   logic q_nx [NX:1];
  logic [NB:0] p_nb;   logic q_nb [NB:1];
  logic [NL:0] p_nl;   logic q_nl [NL:1];

  // --- ADD: two named operands, and a name + a literal -------------------
  logic [NU+MU:0] p_add_nn;   logic q_add_nn [NU+MU:1];
  logic [NU+1:0]  p_add_nl;   logic q_add_nl [NU+1:1];
  logic [1+NU:0]  p_add_ln;   logic q_add_ln [1+NU:1];
  logic [NU+8'd2:0] p_add_nsz; logic q_add_nsz [NU+8'd2:1];
  logic [NB+NB:0] p_add_bb;   logic q_add_bb [NB+NB:1];
  logic [NU+NS:0] p_add_us;   logic q_add_us [NU+NS:1];

  // --- SUB / MUL / DIV / SHIFT ------------------------------------------
  logic [NU-1:0]  p_sub;  logic q_sub [NU-1:1];
  logic [NU*2:0]  p_mul;  logic q_mul [NU*2:1];
  logic [NU/1:0]  p_div;  logic q_div [NU/1:1];
  logic [NU<<1:0] p_shl;  logic q_shl [NU<<1:1];

  // --- literal and system-call bounds -----------------------------------
  logic [7:0]         p_lit;   logic q_lit [7:1];
  logic [8'd7:0]      p_slit;  logic q_slit [8'd7:1];
  logic [$clog2(NU):0] p_clog; logic q_clog [$clog2(NU):1];

  // --- localparam-sourced bounds ----------------------------------------
  localparam int unsigned LU = NU + MU;   // 8
  localparam              LX = NU + MU;   // untyped
  logic [LU:0] p_lu;   logic q_lu [LU:1];
  logic [LX:0] p_lx;   logic q_lx [LX:1];

  always_ff @(posedge clk) p_nu <= '0;
endmodule
