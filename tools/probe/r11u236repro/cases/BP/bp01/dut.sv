// § pkgDefPatSubstShared236 — BlackBePipeInt #15272: pattern members read from a pattern parameter, the parameter array read by a module
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
  parameter cfg_s [2:0] all_p = {mp_p, cust_p, dflt_p};
endpackage
module top import pk::*; #(parameter int sel_p = 1) (output int o);
  localparam cfg_s c_lp = all_p[sel_p];
  assign o = c_lp.a;
endmodule
