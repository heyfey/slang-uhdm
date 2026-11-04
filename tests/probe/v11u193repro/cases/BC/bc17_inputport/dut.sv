// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] a, output logic [7:0] o);
  sub u (.d(7'(a)), .o(o));
endmodule
