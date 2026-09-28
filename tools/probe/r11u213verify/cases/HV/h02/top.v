// § hiddenBlockVarMintNoFile207 (the whole block from an included .v header)
module m (in);
input in;
`include "blk.vh"
endmodule
module top (i);
input i;
m u (i);
endmodule
