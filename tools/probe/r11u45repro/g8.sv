// g8 — the chain in a PACKAGE parameter list (no module header at all).
package pk;
  parameter type a_t = logic [2:0];
  parameter type b_t = a_t;
endpackage
module dut ( input pk::b_t i, output logic o );
  assign o = ^i;
endmodule
