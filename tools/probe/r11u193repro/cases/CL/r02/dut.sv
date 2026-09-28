// § castOperandLeafElab193
module sub (input [3:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
package pk;
  typedef struct packed { logic [2:0] a; logic b; } s_t;
endpackage
module dut import pk::*; (input s_t i, output logic [7:0] o);
  s_t r;
  assign r = i;
  sub u (.d(r), .o(o));
endmodule
