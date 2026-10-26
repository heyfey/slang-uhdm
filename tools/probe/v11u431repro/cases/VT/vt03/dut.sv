// § bodyTypeParamDefKeepsDecl431 (a positional override)
module sub();
parameter type T = int;
T v;
endmodule
module top();
sub #(logic [2:0]) s1 ();
endmodule
