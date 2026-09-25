// § unnamedConcatIfaceAnchor146 § ucpIfaceInstElabShape146
module f({a, b});
input [1:0] a, b;
endmodule
module top;
wire [3:0] x;
f f(x);
endmodule
