module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  logic [31:0] loc;
  assign loc = mv;
  assign mv  = a;
  assign o = loc;
endmodule
