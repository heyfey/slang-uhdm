// § unnamedConcatIfaceAnchor146
module a(a);
input a;
endmodule
module f({a, b});
input a, b;
endmodule
module top;
wire x;
f f(x);
endmodule
