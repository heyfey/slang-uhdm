module top #(parameter int K = 9, parameter int PBal = 1)
  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  logic [3:0] lv;
  assign o3 = {28'd0, lv};
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = '0;
    assign o2 = lv;
  end
endmodule
