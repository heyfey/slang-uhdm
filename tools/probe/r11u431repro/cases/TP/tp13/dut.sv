// § bodyTypeParamDefKeepsDecl431
module sub();
parameter type T = int, U = real;
T v; U w;
endmodule
module top();
sub #(.U(shortreal)) s1 ();
endmodule
