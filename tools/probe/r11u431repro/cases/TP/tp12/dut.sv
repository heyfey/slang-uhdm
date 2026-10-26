// § bodyTypeParamDefKeepsDecl431
package pk; typedef enum logic [1:0] {A, B} e_t; endpackage
module sub();
parameter type T = pk::e_t;
T v;
endmodule
module top();
sub #(.T(int)) s1 ();
endmodule
