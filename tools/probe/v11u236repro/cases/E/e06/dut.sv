// § pkgDefPatSubstShared236 — a read chained through an already-substituted parameter, and the same member read twice in one pattern
package pk;
  typedef struct packed {
    integer unsigned a;
    integer unsigned b;
    integer unsigned c;
  } cfg_s;
  localparam cfg_s dflt_p = '{a: 1, b: 2, c: 3};
  localparam cfg_s cust_p = '{a: dflt_p.a, b: dflt_p.a, c: dflt_p.c};
  localparam cfg_s next_p = '{a: cust_p.a, b: cust_p.b, c: cust_p.c};
  localparam cfg_s last_p = '{a: next_p.b, b: dflt_p.b, c: next_p.c};
endpackage
module top (output int o);
  assign o = 1;
endmodule
