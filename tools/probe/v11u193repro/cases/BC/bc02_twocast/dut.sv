// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] a, input logic [3:0] b, output logic [7:0] o);
  logic [3:0] ra, rb;
  assign ra = a;
  assign rb = b;
  sub u (.d(7'(ra) + 7'(rb)), .o(o));
endmodule
