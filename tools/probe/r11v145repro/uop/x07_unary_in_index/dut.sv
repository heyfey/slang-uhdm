// § unaryOperandParamOwnerName145
module dut #(parameter int M = 0) (input logic [7:0] a, output logic [1:0] o);
  if (1) begin : g
    assign o[0] = a[!M];
  end
endmodule
