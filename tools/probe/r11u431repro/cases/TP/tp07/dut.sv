// § bodyTypeParamDefKeepsDecl431
module sub();
localparam type t_3 = int;
parameter type t_4 = int;
t_3 v3; t_4 v4;
endmodule
module top();
sub #(.t_4(real)) s1 ();
endmodule
