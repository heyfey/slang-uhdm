// § unaryOperandParamOwnerName145 (control: a plain-reference lhs keeps the generate scope's name)
module dut #(parameter M = 3) (input logic [31:0] y, output logic [31:0] x);
  logic [31:0] a [2];
  logic [31:0] o [2];
  if (1) begin : g
    localparam int c = 0;
    assign x = y & ~M;
  end
endmodule
