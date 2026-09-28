// § hiddenBlockVarMintNoFile207: a named-block `logic` the Verilog-mode lexer hides (UnitElabBlock's shape)
module cct (stim1, stim2);
input stim1, stim2;
mod amod(stim1), bmod(stim2);
endmodule
module mod (in);
input in;
always @(posedge in) begin : keep
logic hold;
hold = in;
end
endmodule
