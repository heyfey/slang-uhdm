// § bodyTypeParamDefKeepsDecl431
typedef struct {int A;} t_2;
module sub();
parameter type t_3 = t_2;
t_3 v3;
endmodule
module top();
sub #(.t_3(int)) s1 ();
endmodule
