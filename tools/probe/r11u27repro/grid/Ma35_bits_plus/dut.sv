module top #(parameter int K = 9, parameter int PBal = 1)
  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  logic [31:0] mv;
  assign mv = $bits(a) + 1;
  assign o2 = mv;
endmodule
