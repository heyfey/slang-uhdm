// § castOperandLeafElab193
module sub (input [6:0] d, input [6:0] e, output logic [7:0] o);
  assign o = 8'(d ^ e);
endmodule
module dut (input logic [3:0] i, output logic [7:0] o);
  logic [3:0] r;
  wire [6:0] w;
  assign r = i;
  assign w = 7'(i);
  sub u (w, 7'(r), o);
endmodule
