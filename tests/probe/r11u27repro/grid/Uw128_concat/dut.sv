module top #(parameter int K = 9, parameter int PBal = 1)
  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : gb
    logic [127:0] lv;
    assign lv = {16'd1, 16'd2};
    assign o2 = lv[31:0];
  end
endmodule
