// § pkgDefPatSubstShared236 — shared member reads with a nested struct member, a replicated default, an imported read and a module reading every parameter
package pk;
  typedef struct packed { integer unsigned x; integer unsigned y; } in_s;
  typedef struct packed { in_s i; integer unsigned a; integer unsigned b; } cfg_s;
  localparam cfg_s d_p = '{i: '{x: 3, y: 4}, a: 1, b: 2};
  localparam cfg_s c_p = '{i: d_p.i, a: d_p.i.x, b: d_p.a};
  localparam cfg_s e_p = '{a: d_p.a, default: d_p.b};
  localparam cfg_s f_p = '{i: '{x: c_p.a, y: d_p.i.x}, a: c_p.a, b: e_p.b};
endpackage
package pu;
  import pk::*;
  localparam cfg_s g_p = '{i: d_p.i, a: d_p.a, b: c_p.b};
endpackage
module top import pk::*; (output int o, output int o2);
  assign o = c_p.a + e_p.b + f_p.i.x + f_p.a;
  assign o2 = pu::g_p.a + pu::g_p.b;
endmodule
