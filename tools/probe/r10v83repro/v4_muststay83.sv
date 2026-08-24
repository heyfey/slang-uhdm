// r10v83 arm 4 — THE MUST-STAY CONTROLS.  uvm118's written-tick string fence
// and buvm29's cast-over-stream fence, both placed in THIS law's own context
// (an ELABORATED port High_conn) where they are most exposed, plus a case item
// and a cast of a cast over a stream.  MEASUREMENT ONLY.
typedef logic [15:0] t16_83;
typedef logic [63:0] t64_83;

module snk4_83 (input logic [63:0] a, output logic [63:0] y);
  assign y = ~a;
endmodule
module snkstr4_83 (input string s, output logic [7:0] y);
  assign y = 8'(s.len());
endmodule

module v4_muststay83;
  localparam int W83 = 16;
  logic [63:0] q0,q1,q2,q3,q4,q5,q6;
  logic [7:0]  z0,z1,z2;
  logic [15:0] src4 = 16'hbeef;
  logic [1:0]  sel4;
  string       str4 = "ef";
  logic [63:0] acc4;

  // M01 buvm29: a WRITTEN cast over a STREAM, in an ELAB High_conn -- MUST STAY
  snk4_83 m01 (.a({48'd0, t16_83'({ << bit {src4} })}), .y(q0));
  // M02 buvm29: a written cast over a stream, BARE actual         -- MUST STAY
  snk4_83 m02 (.a({48'd0, t16_83'({ << 8 {src4} })}),             .y(q1));
  // M03 uvm118: a cast inside a STRING CONCAT                     -- MUST STAY
  snkstr4_83 m03 (.s({"ab", string'("cd")}),         .y(z0));
  // M04 uvm118: const'(<string expr>)                             -- MUST STAY
  snkstr4_83 m04 (.s(const'(str4)),                  .y(z1));
  // M05 a compiler-inserted widening (no written tick)            -- MUST STAY
  snk4_83 m05 (.a(src4),                             .y(q2));
  // M06 a cast of a cast whose inner operand is a stream          -- MUST STAY
  snk4_83 m06 (.a({48'd0, t16_83'(t16_83'({ << bit {src4} }))}), .y(q3));
  // M07 the law's own shape, as the positive control              -- FOLD
  snk4_83 m07 (.a(W83'(9)),                          .y(q4));
  // M08 a CASE ITEM in a body always                              -- MUST STAY
  always_comb begin
    case (sel4)
      2'd0:    q5 = W83'(3);
      default: q5 = 64'd0;
    endcase
  end
  // M09 a cast in a case EXPRESSION
  always_comb begin
    case (W83'(1))
      16'd1:   q6 = 64'd1;
      default: q6 = 64'd0;
    endcase
  end
  assign acc4 = q0^q1^q2^q3^q4^q5^q6^{56'd0,z0}^{56'd0,z1};
endmodule
