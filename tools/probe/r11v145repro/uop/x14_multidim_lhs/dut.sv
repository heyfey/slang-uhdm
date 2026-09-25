// § unaryOperandParamOwnerName145
module dut #(parameter logic [3:0] M = 4'h3) (input logic [3:0] a, output logic [1:0][3:0] o);
  if (1) begin : g
    assign o[1][3:0] = a & ~M;
  end
endmodule
