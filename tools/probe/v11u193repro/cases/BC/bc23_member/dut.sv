// § castOperandLeafElab193
package pk;
  typedef struct packed { logic [2:0] a; logic [3:0] b; } s_t;
endpackage
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut import pk::*; (input s_t i, output logic [7:0] o);
  s_t r;
  assign r = i;
  sub u (.d(7'(r.b)), .o(o));
endmodule
