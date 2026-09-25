// § escIdPpColumnShift146
module sub(input i, output o); assign o = ~i; endmodule
module top(input a, output y, output z);
  wire \w$1 ;
  sub \u1  (.i(a), .o(\w$1 )); sub u2 (.i(\w$1 ), .o(y));
  assign z = \w$1  ^ a;
endmodule
