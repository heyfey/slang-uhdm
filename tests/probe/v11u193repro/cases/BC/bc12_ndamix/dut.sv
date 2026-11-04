// § castOperandLeafElab193
module dut (input logic [3:0] a, input logic [3:0] b, output logic [7:0] o);
  logic [3:0] ra, rb;
  assign ra = a;
  assign rb = b;
  wire [7:0] w = 8'(ra) | $unsigned(rb);
  assign o = w;
endmodule
