// § unnamedConcatIfaceAnchor146
module f({a, b});
  input a, b;
endmodule
module top(input x);
  f f(x);
endmodule
