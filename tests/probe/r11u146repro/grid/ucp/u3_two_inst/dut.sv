// § ucpIfaceInstElabShape146
module a(a);
input a;
endmodule
module f({a, b});
input a, b;
endmodule
module top;
wire x, y;
f f1(x);
f f2(y);
endmodule
