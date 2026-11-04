// § bodyTypeParamDefKeepsDecl431
module sub();
parameter type t_3 = logic [7:0];
t_3 v3;
endmodule
module top();
sub #(.t_3(byte)) s1 ();
sub s2 ();
endmodule
