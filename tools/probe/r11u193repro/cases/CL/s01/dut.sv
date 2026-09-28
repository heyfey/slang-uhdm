// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] i, input logic c, output logic [7:0] o);
  logic [3:0] r, q;
  assign r = i;
  assign q = ~i;
  sub u (.d(7'(c ? r : q)), .o(o));
endmodule
