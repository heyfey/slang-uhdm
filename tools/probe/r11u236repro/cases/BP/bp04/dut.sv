// § pkgDefPatSubstShared236 — the same package imported by a second package and a module
package pk;
  typedef struct packed {
    integer unsigned a;
    integer unsigned b;
    integer unsigned c;
  } cfg_s;
  localparam cfg_s dflt_p = '{a: 1, b: 2, c: 3};
  localparam cfg_s cust_p = '{a: dflt_p.a, b: dflt_p.b, c: dflt_p.c};
  localparam cfg_s uni_p = dflt_p;
  localparam cfg_s ovr_p = '{a: 5, default: "inv"};
  localparam cfg_s mp_p = '{
    a: (ovr_p.a == "inv") ? uni_p.a : ovr_p.a,
    b: (ovr_p.b == "inv") ? uni_p.b : ovr_p.b,
    c: (ovr_p.c == "inv") ? uni_p.c : ovr_p.c
  };
  localparam cfg_s mrg_p = '{a: cust_p.a, b: mp_p.b, c: (1 << 2) | (1 << 0)};
endpackage
package pk2;
  import pk::*;
  localparam cfg_s two_p = '{a: mp_p.a, b: dflt_p.b, c: 7};
endpackage
module top import pk2::*; (output int o);
  assign o = 2;
endmodule
