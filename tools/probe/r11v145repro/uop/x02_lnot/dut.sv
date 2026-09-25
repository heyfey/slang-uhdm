// § unaryOperandParamOwnerName145
module dut #(parameter bit M = 1'b0) (input logic [1:0] a, output logic [1:0] o);
  if (1) begin : g
    assign o[1] = a[1] & !M;
  end
endmodule
