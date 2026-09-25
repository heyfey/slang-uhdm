// § unnamedConcatIfaceAnchor146 § ucpIfaceInstElabShape146
module f({a, b});
output a, b;
assign a = 1'b0;
assign b = 1'b1;
endmodule
module top;
wire [1:0] x;
f f(x);
endmodule
