// § bodyTypeParamDefKeepsDecl431 (two declarations of type parameters)
module sub();
parameter type T = int;
parameter type U = logic [3:0];
T v; U w;
endmodule
module top();
sub #(.U(byte), .T(shortint)) s1 ();
endmodule
