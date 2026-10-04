// § pkgDefPatSubstShared236 — two packages' definition listings read the same member of a third package's pattern parameter
package pa;
  typedef struct packed { integer unsigned a; integer unsigned b; } cfg_s;
  localparam cfg_s dflt_p = '{a: 1, b: 2};
endpackage
package pb;
  localparam pa::cfg_s c1 = '{a: pa::dflt_p.a, b: pa::dflt_p.b};
  localparam pa::cfg_s c2 = '{a: pa::dflt_p.b, b: pa::dflt_p.a};
endpackage
package pc;
  localparam pa::cfg_s c3 = '{a: pa::dflt_p.a, b: 7};
endpackage
module top (output int o);
  assign o = pb::c1.a + pc::c3.a + pb::c2.b;
endmodule
