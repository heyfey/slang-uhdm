module top #(parameter int K = 9, parameter int PBal = 1)
  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : gb
    logic [15:0] lv1;
    logic [15:0] lv2;
    assign {lv1, lv2} = '0;
    assign o2 = {lv1, lv2};
  end
endmodule
