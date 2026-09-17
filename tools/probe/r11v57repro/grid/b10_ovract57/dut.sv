// r11v57 B10 — the initializer the elaborated arm emits is the OVERRIDE ACTUAL
// (§ elabOvMisevalNoFold picks `boundInit`), and the actual holds the buried
// call.  A different `init0` reaches the same hook.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module child #(parameter type TP = logic [1:0], parameter int DEPTH = 4)
              (output logic o);
  assign o = ^{DEPTH[0]};
endmodule
module dut #(parameter type QT = logic [3:0]) (output logic o);
  logic a, b;
  child #(.TP(QT), .DEPTH(1 + $bits(QT)))        u1 (.o(a));  // actual holds the call
  child #(.TP(QT), .DEPTH(1 + $bits(pk::req_t))) u2 (.o(b));  // CONTROL actual
  assign o = a ^ b;
endmodule
