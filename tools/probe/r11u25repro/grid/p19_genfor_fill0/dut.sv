module top #(parameter int K = 9, parameter int PBal = 1)
  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  for (genvar i = 0; i < 2; i++) begin : gf
    logic [31:0] lv;
    assign lv = '0;
  end
  assign o2 = gf[0].lv;
endmodule
