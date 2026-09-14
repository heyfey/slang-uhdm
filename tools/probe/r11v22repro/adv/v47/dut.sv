module top(input logic [31:0] a, output logic [31:0] o);
  wire [31:0] w;
  if (1) begin : gb
    assign o = (1) ? 32'hDEAD_BEEF : '0;
  end
endmodule
