// withdrawn: macroVecLitTokenText401 (see README)
`define fi_type(op, funct3, funct12) {``funct12``,{5{1'b?}},``funct3``,{5{1'b?}},``op``}
module top(input logic [31:0] instr, output logic y);
  always_comb begin
    y = 1'b0;
    casez (instr)
      `fi_type(7'b1010011, 3'b000, 12'b111000000000): y = 1'b1;
      default: ;
    endcase
  end
endmodule
