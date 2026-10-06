// § forInitSelectLhsBase254 (fresh: v05 without the package-qualified base: an indexed part-select target, a two-dimensional element, two initializers)
package pv; typedef struct { int a; } s_t; s_t gs; endpackage
module top(output int o);
  logic [15:0] v; int m [2][2];
  initial begin
    o = 0;
    for (v[4 +: 4] = 0; v[4 +: 4] < 3; v[4 +: 4]++) o++;
    for (m[1][0] = 0; m[1][0] < 2; m[1][0]++) o++;
    for (int i = 0, j = 0; i < 2; i++) o++;
  end
endmodule
