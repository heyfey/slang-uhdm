// § bodyTypeParamDefKeepsDecl431 (a struct default overridden with a typedef)
typedef logic [5:0] u_t;
module sub();
parameter type T = struct packed { logic a; logic [1:0] b; };
T v;
endmodule
module top();
sub #(.T(u_t)) s1 ();
endmodule
