// § unaryOperandParamOwnerName145
module dut #(parameter M = 3) (input logic [31:0] y, output logic [31:0] x);
  logic [31:0] a [2];
  logic [31:0] o [2];
  if (1) begin : g
    localparam int c = 0;
    assign x[3:0] = y[3:0] & ~M;
  end
endmodule
