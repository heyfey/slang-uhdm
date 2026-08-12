// r10earl30 arm g1_ctx.sv — AXIS (b): the CONTEXT a PACKAGE ENUM LITERAL is
// folded in.  Origin is held FIXED at the witness's origin (a package enum
// literal whose enum base type is `logic [2:0]`, exactly dm::cmderr_e), and the
// member is held at BOTH the zero-valued FIRST member (dm::CmdErrNone, the
// witness) and a NONZERO member (dm::CmdErrBusy, named by the brief).
//
// PREDICTION UNDER TEST: golden writes vpiConstType 7 (vpiIntConst) for the
// COMPARISON-operand cell.  If the discriminator is the ORIGIN, every cell here
// reads 7; if it is the CONTEXT, only some do.
package p1;
  typedef enum logic [2:0] {
    E0, E1, E2, E3 = 7
  } e_t;
endpackage

module g1_ctx (input logic [2:0] q, output logic [7:0] o);

  logic [2:0] r;
  logic       hit0, hit1;
  logic [2:0] mem [0:7];
  logic [7:0] cat;

  // o1  COMPARISON operand, ZERO member  — THE EARLGREY WITNESS CELL
  // o2  COMPARISON operand, NONZERO member
  always_comb begin
    if (q == p1::E0)      r = 3'd1;
    else if (q == p1::E1) r = 3'd2;
    else                  r = 3'd3;
  end

  // o3  comparison inside a continuous-assign expression, ZERO member
  assign hit0 = (q == p1::E0);
  // o4  comparison, NONZERO member, continuous assign
  assign hit1 = (q == p1::E2);

  // o5  ASSIGNMENT RHS (procedural), ZERO member
  // o6  ASSIGNMENT RHS (procedural), NONZERO member
  always_comb begin
    if (q[0]) o[2:0] = p1::E0;
    else      o[2:0] = p1::E1;
  end

  // o7  INDEX of a select
  assign o[3] = mem[p1::E1][0];

  // o8  CONCATENATION element
  assign cat = {5'b0, p1::E2};

  // o9  case ITEM
  always_comb begin
    case (q)
      p1::E0:  o[7:4] = 4'd1;
      p1::E1:  o[7:4] = 4'd2;
      default: o[7:4] = 4'd0;
    endcase
  end

  // o10 localparam initializer (a WRITTEN parameter, not a folded operand)
  localparam int LP = p1::E1;

  // o11 packed RANGE BOUND
  logic [p1::E3:0] wide;
  assign wide = 8'd0;

endmodule
