// § pkgDefPatSubstShared236 — a localparam typed int reading a member, an unpacked-array parameter of patterns and a parameter (not localparam)
package pk;
  typedef struct packed {
    integer unsigned a;
    integer unsigned b;
    integer unsigned c;
  } cfg_s;
  localparam cfg_s dflt_p = '{a: 1, b: 2, c: 3};
  parameter cfg_s par_p = '{a: dflt_p.a, b: dflt_p.b, c: 1};
  localparam int ia = dflt_p.a;
  localparam cfg_s arr_p [2] = '{'{a: dflt_p.a, b: 1, c: 2}, '{a: dflt_p.a, b: dflt_p.b, c: 3}};
endpackage
module top (output int o);
  assign o = 1;
endmodule
