// § bodyTypeParamDefKeepsDecl431 (a package typedef default)
package pk; typedef logic [2:0] t3; endpackage
module sub();
parameter type T = pk::t3;
T v;
endmodule
module top();
sub #(.T(shortint)) s1 ();
endmodule
