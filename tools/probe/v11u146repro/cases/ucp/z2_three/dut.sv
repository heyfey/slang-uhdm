// § unnamedConcatIfaceAnchor146
module f({a, b, c});
  input a, b, c;
endmodule
module top(input x);
  f f(x);
endmodule
