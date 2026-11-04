// § unaryOperandParamOwnerName145
module dut(input logic [7:0] a [2], output logic [7:0] o [2]);
  localparam logic [7:0] M = 8'hf0;
  if (1) begin : g
    assign o[1] = a[1] | ~M;
  end
endmodule
