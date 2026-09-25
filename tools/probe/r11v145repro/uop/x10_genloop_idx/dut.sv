// § unaryOperandParamOwnerName145
module dut #(parameter logic [7:0] M = 8'h0f) (input logic [7:0] a [4], output logic [7:0] o [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign o[i] = a[i] ^ ~M;
  end
endmodule
