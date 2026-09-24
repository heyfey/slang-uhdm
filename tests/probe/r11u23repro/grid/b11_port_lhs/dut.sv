module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : gb
    assign o2 = a & 32'hff;
  end
endmodule
