// § strLitContOwnerEnd224
module m #(parameter string S = "") (output string o); assign o = S; endmodule
module top(input logic c, output string o);
  m #(.S(1 ? "x" : "ab \
cd")) u(.o(o));
endmodule
