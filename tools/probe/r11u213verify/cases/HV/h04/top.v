// § hiddenBlockVarMintNoFile207 (the hidden name equal to an implicit net of a port connection elsewhere; two modules hiding one name)
module leaf (a, y);
input a;
output y;
assign y = a;
endmodule
module m1 (in);
input in;
leaf l (in, hold);
endmodule
module m2 (in);
input in;
always @(posedge in) begin : k
logic hold;
hold = in;
end
endmodule
module m3 (in);
input in;
always @(negedge in) begin : k
logic hold, other;
other = in;
hold = other;
end
endmodule
module top (i);
input i;
m1 a (i);
m2 b (i);
m3 c (i);
endmodule
