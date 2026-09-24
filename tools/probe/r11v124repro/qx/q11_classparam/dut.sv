// § pkgQualFoldSpanByView124
package pk; parameter int X = 5; endpackage
class C #(int N = pk::X); function int f(); return N; endfunction endclass
module top(output int o); C c; initial begin c = new; o = c.f(); end endmodule
