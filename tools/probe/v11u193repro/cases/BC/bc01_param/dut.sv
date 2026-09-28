// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (output logic [7:0] o);
  localparam int P = 5;
  sub u (.d(7'(P)), .o(o));
endmodule
