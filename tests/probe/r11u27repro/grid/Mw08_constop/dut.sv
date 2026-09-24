module top #(parameter int K = 9, parameter int PBal = 1)
  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  logic [7:0] mv;
  assign mv = 32'd2 + 32'd3;
  assign o2 = {24'd0, mv};
endmodule
