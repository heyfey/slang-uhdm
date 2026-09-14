module top #(parameter int K = 9)
  (input logic [31:0] a, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : gb
    logic [7:0] lv;
    assign lv = a[7:0];
    assign o2 = {24'd0, lv};
  end
endmodule
