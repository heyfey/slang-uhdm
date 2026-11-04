// § paramValueIsDefRhs124
class C #(int N = 3); int a; function int sz(); return N; endfunction endclass
module top(output int o); C #(5) c; initial begin c = new; o = c.sz(); end endmodule
