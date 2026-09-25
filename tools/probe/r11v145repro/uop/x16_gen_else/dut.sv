// § unaryOperandParamOwnerName145
module dut #(parameter logic [7:0] M = 8'h0f, parameter bit E = 0) (input logic [7:0] a [2], output logic [7:0] o [2]);
  if (E) begin : g
    assign o[0] = a[0];
  end else begin : h
    assign o[0] = a[0] & ~M;
  end
endmodule
