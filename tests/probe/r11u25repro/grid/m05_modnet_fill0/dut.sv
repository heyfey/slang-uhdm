module top #(parameter int K = 9, parameter int PBal = 1)
  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  wire [31:0] mw;
  assign mw = '0;
  assign o2 = mw;
endmodule
