// § unaryOperandParamOwnerName145
module dut #(parameter logic [7:0] M = 8'h0F) (input logic s);
  logic [7:0] a [2];
  logic [7:0] o [2];
  if (1) begin : g
    localparam int c = 1;
    assign o[c] = s ? ~M : a[c];
  end
endmodule
