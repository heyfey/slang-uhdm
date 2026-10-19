// § macroVecLitTokenText403
`define LIT 8'hA5
`define MK(a) {``a``, 4'b1x?0}
module top(input [11:0] i, output logic y);
  logic [7:0] v = `LIT;
  always_comb casez (i) `MK(8'h1z): y = 1; default: y = 0; endcase
endmodule
