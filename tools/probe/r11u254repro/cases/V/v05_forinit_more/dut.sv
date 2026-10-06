// § forInitSelectLhsBase254 (fresh: an indexed part-select target, a package-variable member, a two-dimensional element and a for loop with two initializers)
package pv; typedef struct { int a; } s_t; s_t gs; endpackage
module top(output int o);
  logic [15:0] v; int m [2][2];
  initial begin
    o = 0;
    for (v[4 +: 4] = 0; v[4 +: 4] < 3; v[4 +: 4]++) o++;
    for (pv::gs.a = 0; pv::gs.a < 2; pv::gs.a++) o++;
    for (m[1][0] = 0; m[1][0] < 2; m[1][0]++) o++;
    for (int i = 0, j = 0; i < 2; i++) o++;
  end
endmodule
