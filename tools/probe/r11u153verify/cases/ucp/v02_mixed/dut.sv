// § unnamedConcatIfaceAnchor146 § ucpIfaceInstElabShape146
module f({a, b}, c);
input a, b, c;
endmodule
module top;
wire [1:0] x;
wire y;
f f(x, y);
endmodule
