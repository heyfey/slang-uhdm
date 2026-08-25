// r10uvm146 arm B — PARAMETER KINDS through one $unit wildcard import, plus the
// compilation unit's OWN parameter (the own-vs-imported ORDER question), and
// referenced vs unreferenced names.
package kinds_pk;
  parameter        K_plain   = 42;            // untyped literal
  parameter int    K_typed   = 7;             // typed
  parameter string K_str     = "kay";         // string
  parameter        K_expr    = K_plain + K_typed * 2;   // expression of others
  localparam       K_local   = 13;            // localparam
  parameter type   K_type    = logic [3:0];   // TYPE parameter
  parameter        K_unref   = 99;            // never referenced anywhere
endpackage

parameter UNIT_OWN_1 = 100;                   // the unit's own, declared FIRST
import kinds_pk::*;
parameter unit_own_2 = 101;                   // and one declared AFTER the import

module b_kinds(output int r1, output int r2, output int r3);
  K_type kv;
  assign r1 = K_plain + K_typed + K_local;
  assign r2 = K_expr + UNIT_OWN_1 + unit_own_2;
  assign r3 = K_str.len() + $bits(kv);
endmodule
