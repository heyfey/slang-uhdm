// § bodyTypeParamDefKeepsDecl431
module sub();
parameter type t_3 = int;
t_3 v3;
endmodule
module top();
sub #(.t_3(logic [3:0])) s1 ();
endmodule
