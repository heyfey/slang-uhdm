// § pkgDefPatHomeOnly236v — one other package reads the same member of the declaring package's pattern in two parameters
package pk;
  typedef struct packed {
    integer unsigned a;
    integer unsigned b;
    integer unsigned c;
  } cfg_s;
  localparam cfg_s dflt_p = '{a: 1, b: 2, c: 3};
  localparam cfg_s own_p = '{a: dflt_p.a, b: 8, c: 9};
endpackage
package pb;
  localparam pk::cfg_s pb_p = '{a: pk::dflt_p.a, b: 4, c: 5};
  localparam pk::cfg_s pb_q = '{a: pk::dflt_p.a, b: 6, c: 7};
endpackage
module top (output int o);
  assign o = 1;
endmodule
