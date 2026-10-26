// § bodyTypeParamDefKeepsDecl431
module sub();
parameter type t_3 = int;
t_3 v3;
endmodule
module top();
typedef struct {int A;} t_6;
sub #(.t_3(t_6)) s1 ();
endmodule
