// § pkgDefPatHomeOnly236v — two other packages read the same member, the declaring package does not
package pk;
  typedef struct packed {
    integer unsigned a;
    integer unsigned b;
    integer unsigned c;
  } cfg_s;
  localparam cfg_s dflt_p = '{a: 1, b: 2, c: 3};
endpackage
package pb;
  localparam pk::cfg_s pb_p = '{a: pk::dflt_p.a, b: 4, c: 5};
endpackage
package pc;
  localparam pk::cfg_s pc_p = '{a: pk::dflt_p.a, b: 6, c: 7};
endpackage
module top (output int o);
  assign o = 1;
endmodule
