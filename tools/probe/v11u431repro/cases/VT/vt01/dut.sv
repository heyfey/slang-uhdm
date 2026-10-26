// § bodyTypeParamDefKeepsDecl431 (a default naming another type parameter)
module sub();
parameter type T = int, U = T;
T v; U w;
endmodule
module top();
sub #(.T(byte)) s1 ();
endmodule
