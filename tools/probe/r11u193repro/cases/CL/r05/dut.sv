// § castOperandLeafElab193
typedef logic [6:0] w_t;
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] i, output logic [7:0] o);
  logic [3:0] r;
  assign r = i;
  sub u (.d(w_t'(r)), .o(o));
endmodule
