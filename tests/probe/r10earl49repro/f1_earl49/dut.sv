// f1: the TERNARY-RECURSION fence, transcribed from prim_filter_ctr.sv:54-56
// (the Earlgrey shape that over-fired on all 32 u_gpio.gen_filter[i] copies
// when the recursion entered every operation operand).
module f1_earl49 #(parameter int unsigned Cycles = 16) (
  input  logic clk_i, rst_ni, filter_i,
  output logic [3:0] diff_ctr_d, taken_d
);
  localparam int unsigned CTR_WIDTH = $clog2(Cycles);
  localparam logic [CTR_WIDTH-1:0] CYCLESM1 = (CTR_WIDTH)'(Cycles-1);
  localparam logic [CTR_WIDTH-1:0] TAKEN    = (CTR_WIDTH)'(Cycles-2);
  logic [CTR_WIDTH-1:0] diff_ctr_q;
  logic filter_q;
  // F1: the condition reads two VARIABLES, so the reducer stops at it and the
  // nested ternary holding CYCLESM1 is never entered -> golden LOCATED.
  assign diff_ctr_d =
             (filter_i != filter_q)           ? '0       :
                     (diff_ctr_q == CYCLESM1) ? CYCLESM1 :
                         (diff_ctr_q + 1'b1);
  // F2: the same nesting with a CONSTANT-FOLDING condition -> the reducer does
  // enter the taken branch.
  assign taken_d =
             (Cycles > 0)                     ? ((diff_ctr_q == TAKEN) ? TAKEN : '0)
                                              : '0;
endmodule
