// § stdRandomizeIsScopeRef403
module top;
  int a, b;
  initial if (!std::randomize(a, b)) $display("fail");
endmodule
