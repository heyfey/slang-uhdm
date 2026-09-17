// r11u57 — THE BOUNDARY THE WIDENED GATE COULD OVERRUN.  The gate asks "does
// this initializer CONTAIN a `$bits(<type parameter>)`", so the arm has to ask
// whether an enclosing expression can still REDUCE with such a call inside it.
// Surelog's elaborated reduce answers a constant-condition CONDITIONAL with
// the TAKEN BRANCH's own value (§ elabTernaryBranchFold), so a `$bits` in the
// branch NOT taken is unreachable to the result; a `&&` with a constant-false
// left operand is the same question for a short circuit.  If golden folds any
// of these and we emit them symbolically, that is AWAY-GOLDEN and the gate
// needs a reachability test rather than a containment test.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut #(parameter type TP = logic [1:0]) (output logic o);
  localparam int T1 = (1) ? 7 : $bits(TP);        // NOT-taken branch
  localparam int T2 = (0) ? 7 : $bits(TP) + 1;    // TAKEN branch has the call
  localparam int T3 = (1'b0) && ($bits(TP) > 0);  // short circuit
  localparam int T4 = (1) ? 7 : $bits(pk::req_t); // CONTROL
  localparam int T5 = ($bits(TP) > 0) ? 7 : 9;    // the call is in the CONDITION
  localparam int T6 = 1 + ((0) ? 7 : $bits(TP));  // INTERIOR conditional, taken
  localparam int T7 = 1 + ((1) ? 7 : $bits(TP));  // INTERIOR conditional, not taken
  assign o = ^{T1[0], T2[0], T3, T4[0], T5[0], T6[0], T7[0]};
endmodule
