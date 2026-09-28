// § hiddenBlockVarMintNoFile207: the hidden variable read twice and written in two modules (first reference span, one wire per module)
module a (in, o);
input in; output reg o;
always @(in) begin : blk
logic h;
h = in;
o = h;
end
endmodule
module b (in);
input in;
initial begin : ib
logic h2;
h2 = in;
end
endmodule
module top(input i, output o); a ua(i, o); b ub(i); endmodule
