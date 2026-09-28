// § hiddenBlockVarMintNoFile207: hidden block logic in a leaf instantiated three levels down, next to a real implicit net from a port connection
module leaf (in);
input in;
always @(in) begin : k
logic v;
v = in & in;
end
endmodule
module mid (in);
input in;
leaf l1(w1);
leaf l2(in);
assign w1 = in;
endmodule
module top (i);
input i;
mid m1(i);
mid m2(i);
endmodule
