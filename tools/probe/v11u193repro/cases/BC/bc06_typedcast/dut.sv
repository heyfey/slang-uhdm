// § castOperandLeafElab193
package pk;
  typedef logic [6:0] w_t;
endpackage
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] a, output logic [7:0] o);
  logic [3:0] r;
  assign r = a;
  sub u (.d(pk::w_t'(r)), .o(o));
endmodule
