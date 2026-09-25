// § unaryOperandParamOwnerName145
module dut #(parameter int unsigned M = 32'd4095) ();
  logic [31:0] a [2];
  logic [31:0] o [2];
  if (1) begin : g
    localparam int c = 0;
    assign o[c] = a[c] & -M;
  end
endmodule
