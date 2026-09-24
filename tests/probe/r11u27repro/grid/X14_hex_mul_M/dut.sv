module top(input logic [31:0] a, output logic [31:0] o2);
  logic [31:0] mv;
  assign mv = 32'h2 * 32'h3;
  assign o2 = mv;
endmodule
