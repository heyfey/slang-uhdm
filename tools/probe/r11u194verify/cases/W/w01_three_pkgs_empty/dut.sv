// § ifaceTwoPkgTdNameOrder186: an interface wildcard-importing three packages, one without typedefs, the typedef names interleaving across packages (a_t p3, b_t p1, c_t p3, d_t p1)
package p1;
  typedef logic [1:0] d_t;
  typedef logic [2:0] b_t;
  parameter int X = 1;
endpackage
package p2;
  parameter int Y = 2;
endpackage
package p3;
  typedef logic [3:0] c_t;
  typedef logic [4:0] a_t;
endpackage
interface bus_if;
  import p1::*;
  import p2::*;
  import p3::*;
  a_t a;
  b_t b;
  c_t c;
  d_t d;
endinterface
module top;
  bus_if bi ();
endmodule
