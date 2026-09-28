// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic c, input logic [3:0] a, input logic [3:0] b, output logic [7:0] o);
  logic rc;
  logic [3:0] ra, rb;
  assign rc = c;
  assign ra = a;
  assign rb = b;
  sub u (7'(rc ? ra : rb), o);
endmodule
