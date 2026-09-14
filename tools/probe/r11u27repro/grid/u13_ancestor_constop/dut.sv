module top #(parameter int K = 9, parameter int PBal = 1)
  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : g1
    logic [31:0] ov;
    if (1) begin : g2
      assign ov = 32'd2 + 32'd3;
    end
    assign o2 = ov;
  end
endmodule
