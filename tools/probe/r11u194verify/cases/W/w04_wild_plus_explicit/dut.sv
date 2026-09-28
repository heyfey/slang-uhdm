// § ifaceTwoPkgTdNameOrder186 (the law abstains): two wildcard imports plus an explicit import of a third package's typedef
package p1;
  typedef logic [1:0] b_t;
endpackage
package p2;
  typedef logic [2:0] a_t;
endpackage
package p3;
  typedef logic [3:0] c_t;
  typedef logic [4:0] d_t;
endpackage
interface bus_if;
  import p1::*;
  import p2::*;
  import p3::c_t;
  a_t a;
  b_t b;
  c_t c;
endinterface
module top;
  bus_if bi ();
endmodule
