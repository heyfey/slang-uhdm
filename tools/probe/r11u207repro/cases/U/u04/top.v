// § hiddenBlockVarMintNoFile207: a hidden block variable in an included file and a macro-born read
`include "inc.vh"
module m (in);
input in;
always @(posedge in) begin : keep
logic hold;
`RD(hold, in)
end
endmodule
