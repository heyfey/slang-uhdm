// § bodyTypeParamDefKeepsDecl431 (two instances with different overrides)
module sub();
parameter type T = int;
T v;
endmodule
module top();
sub #(.T(byte)) s1 ();
sub #(.T(logic [5:0])) s2 ();
endmodule
