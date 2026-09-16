// r11u53 ROAD A blast-radius shape — the type parameter is OVERRIDDEN at the
// instantiation (the `type_param_override_elem_sel` / `type_param_packed_dim`
// witnesses' shape).  The child module then has TWO elaborated copies to look
// at: the definition listing (TP still at its default) and the instance's
// elaborated copy (TP bound to the override).  If the producer decided on the
// RESOLVED type, the override would be the cell that moved; the law says the
// decision is on the argument's SYNTAX, so BOTH copies keep the call.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
  typedef logic [11:0] small_t;                                             // 12
endpackage
module child #(
    parameter type TP = pk::req_t
) (
    output logic o
);
  localparam int CW = $bits(TP);
  assign o = ^{CW[0]};
endmodule
module dut (output logic o);
  logic a, b;
  child            u0 (.o(a));                       // default  -> 97
  child #(.TP(pk::small_t)) u1 (.o(b));              // override -> 12
  assign o = a ^ b;
endmodule
