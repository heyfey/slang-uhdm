// § bodyTypeParamDefKeepsDecl431 (override with the same type as the default)
module sub();
parameter type T = int;
T v;
endmodule
module top();
sub #(.T(int)) s1 ();
endmodule
