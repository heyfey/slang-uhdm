module top #(parameter int K = 9)
  (input logic [31:0] a, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : gb
    wire [31:0] lw;
    assign #1 lw = '0;
    assign o2 = lw;
  end
endmodule
