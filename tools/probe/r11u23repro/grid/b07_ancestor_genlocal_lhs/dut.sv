module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : g1
    logic [31:0] ov;
    assign o2 = ov;
    if (1) begin : g2
      assign ov = a & 32'hff;
    end
  end
endmodule
