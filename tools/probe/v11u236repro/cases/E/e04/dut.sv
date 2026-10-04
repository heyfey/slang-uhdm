// § pkgDefPatHomeOnly236v — a second package's definition listing reads the same members (cross-package sharing)
package pk;
  typedef struct packed {
    integer unsigned a;
    integer unsigned b;
    integer unsigned c;
  } cfg_s;
  localparam cfg_s dflt_p = '{a: 1, b: 2, c: 3};
  localparam cfg_s cust_p = '{a: dflt_p.a, b: dflt_p.b, c: dflt_p.c};
endpackage
package pb;
  localparam pk::cfg_s pb_p = '{a: pk::dflt_p.a, b: pk::dflt_p.b, c: 9};
endpackage
module top (output int o);
  assign o = 1;
endmodule
