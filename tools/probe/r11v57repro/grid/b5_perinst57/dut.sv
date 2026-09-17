// r11v57 B5 — the conditional's condition is an OVERRIDDEN VALUE parameter, so
// `knownSide()` answers DIFFERENTLY PER INSTANCE and so does the producer's
// per-instance reduce.  If slang's bind-time `isConst` and Surelog's elaborated
// reduce disagree for either copy, the reachability rule breaks.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module child #(parameter type TP = logic [1:0], parameter int SEL = 1)
              (output logic o);
  localparam int P1 = (SEL) ? $bits(TP) : 7;      // call REACHED only when SEL
  localparam int P2 = (SEL) ? 7 : $bits(TP);      // call reached only when !SEL
  localparam int P3 = (SEL == 0) ? ($bits(TP) + 1) : 9;
  assign o = ^{P1[0], P2[0], P3[0]};
endmodule
module dut(output logic o);
  logic a, b;
  child #(.TP(logic [3:0]), .SEL(1)) u1 (.o(a));
  child #(.TP(logic [3:0]), .SEL(0)) u2 (.o(b));
  assign o = a ^ b;
endmodule
