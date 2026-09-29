// § strLitContLineSpan220
module sub #(parameter string P = "x") (output string o);
  assign o = P;
endmodule
module top(output string o);
  sub #(.P("ov\
er")) u(.o(o));
endmodule
