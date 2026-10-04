// § pkgDefPatSubstShared236 — member reads in a ternary, beside an arithmetic member, and a module reading the package parameters
package pk;
  typedef struct packed {
    integer unsigned a;
    integer unsigned b;
    integer unsigned c;
  } cfg_s;
  localparam cfg_s dflt_p = '{a: 1, b: 2, c: 3};
  localparam cfg_s ovr_p = '{a: 5, b: 0, c: 0};
  localparam cfg_s cust_p = '{a: (ovr_p.a == 0) ? dflt_p.a : ovr_p.a, b: dflt_p.b + 1, c: dflt_p.c};
  localparam cfg_s more_p = '{a: dflt_p.a, b: (ovr_p.b == 0) ? dflt_p.b : ovr_p.b, c: 4};
endpackage
module top (output int o, output int o2);
  assign o = pk::cust_p.a + pk::more_p.b;
  assign o2 = pk::dflt_p.c;
endmodule
