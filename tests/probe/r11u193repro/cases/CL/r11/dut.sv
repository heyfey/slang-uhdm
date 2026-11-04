// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] i, output logic [7:0] o);
  logic [3:0] r;
  assign r = i;
  wire [6:0] w = 7'(r);
  sub u (.d(w), .o(o));
endmodule
