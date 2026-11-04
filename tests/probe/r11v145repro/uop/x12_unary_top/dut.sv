// § unaryOperandParamOwnerName145
module dut #(parameter logic [7:0] M = 8'h0f) (output logic [7:0] o [2]);
  if (1) begin : g
    assign o[0] = ~M;
  end
endmodule
