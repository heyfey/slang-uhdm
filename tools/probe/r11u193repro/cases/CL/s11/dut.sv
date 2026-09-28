// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (i, o);
  input [3:0] i;
  output [7:0] o;
  wire [6:0] w = 7'(i);
  sub u (.d(w), .o(o));
endmodule
