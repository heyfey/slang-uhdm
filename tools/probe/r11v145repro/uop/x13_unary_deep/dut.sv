// § unaryOperandParamOwnerName145
module dut #(parameter logic [7:0] M = 8'h0f) (input logic [7:0] a [2], output logic [7:0] o [2]);
  if (1) begin : g
    assign o[0] = a[0] & (~M | a[1]);
  end
endmodule
