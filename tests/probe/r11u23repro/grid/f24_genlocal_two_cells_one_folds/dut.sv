module top #(parameter int K = 9)
  (input logic [31:0] a, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : gb
    logic [31:0] lv, lw;
    assign lv = '0;
    assign lw = a & 32'hff;
    assign o2 = lv ^ lw;
  end
endmodule
