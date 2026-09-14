module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  wire [31:0] mw;
  assign o2 = mw;
  if (1) begin : gb
    assign mw = a & 32'hff;
  end
endmodule
