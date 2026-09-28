// § hiddenBlockVarMintNoFile207: control, a `reg` block variable (a Verilog keyword: declared, no mint)
module m (in);
input in;
always @(posedge in) begin : keep
reg hold;
hold = in;
end
endmodule
