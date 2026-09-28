// § hiddenBlockVarMintNoFile207 (a .v module beside a .sv sibling that declares the same block variable visibly)
module vm (in);
input in;
always @(posedge in) begin : kb
logic hold;
hold = in;
end
endmodule
