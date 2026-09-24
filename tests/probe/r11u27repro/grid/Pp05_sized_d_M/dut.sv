module top(input logic [31:0] a, output logic [31:0] o2);
  parameter P = 32'd9;
  logic [31:0] mv;
  assign mv = P + 32'd1;
  assign o2 = mv;
endmodule
