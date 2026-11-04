// § bodyTypeParamDefKeepsDecl431
module sub();
parameter type T = logic [3:0];
T v;
endmodule
module top();
typedef struct packed {logic a; logic b;} s_t;
sub #(.T(s_t)) s1 ();
sub #(.T(logic [7:0])) s2 ();
endmodule
