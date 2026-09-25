// § unnamedConcatIfaceAnchor146 § ucpIfaceInstElabShape146
module f({a, b});
input a, b;
endmodule
module top;
wire [1:0] x, y;
f f1(x);
f f2(y);
endmodule
