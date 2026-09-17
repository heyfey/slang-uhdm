// r11v57 B9 — the FENCE under stress.  `elabCondBranch57` descends only the
// TOP-LEVEL conditional chain and `interiorCondFold57` refuses anything below.
// These shapes sit on the seam.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut #(parameter type TP = logic [1:0]) (output logic o);
  localparam int D1 = (0) ? 7 : ((1) ? 9 : $bits(TP));       // chain, call unreachable twice
  localparam int D2 = (0) ? 7 : ((0) ? 9 : $bits(TP) + 1);   // chain, call reached at depth 2
  localparam int D3 = (0) ? 7 : ($bits(TP) + ((1) ? 2 : 3)); // taken branch holds an INTERIOR cond
  localparam int D4 = ($bits(TP) > 0) ? ((0) ? 7 : 8) : 9;   // condition has the call, interior cond in a branch
  localparam int D5 = (1) ? $bits(TP) : 7;                   // taken branch IS the call
  assign o = ^{D1[0], D2[0], D3[0], D4[0], D5[0]};
endmodule
