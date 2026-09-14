module top(input logic [31:0] a, output logic [31:0] o2);
  parameter logic [7:0] P = 8'd9;
  logic [31:0] mv;
  assign mv = P + 32'd1;
  assign o2 = mv;
endmodule
