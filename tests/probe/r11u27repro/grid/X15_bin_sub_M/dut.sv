module top(input logic [31:0] a, output logic [31:0] o2);
  logic [31:0] mv;
  assign mv = 32'b111 - 32'b11;
  assign o2 = mv;
endmodule
