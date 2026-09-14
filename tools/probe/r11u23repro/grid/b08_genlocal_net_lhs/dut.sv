module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : gb
    wire [31:0] lw;
    assign lw = a & 32'hff;
    assign o2 = lw;
  end
endmodule
