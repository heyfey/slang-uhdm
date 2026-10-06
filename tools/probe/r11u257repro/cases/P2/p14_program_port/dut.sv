// § implicitPortTsFirstDim257 (a program port with two packed dimensions and no type keyword)
program prg(input [3:0][1:0] a); initial $display(a); endprogram
module top; logic [3:0][1:0] a; prg u(.a(a)); endmodule
