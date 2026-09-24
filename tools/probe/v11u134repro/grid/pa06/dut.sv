// § typedefParentLastWriter134
package p;
  typedef struct packed { logic [3:0] x; logic y; } t;
endpackage
interface ifa;
  import p::*;
  t a;
endinterface
interface ifz import p::*; ();
  t z;
endinterface
module top(output logic [3:0] o);
  ifa ia();
  ifz iz();
  assign o = ia.a.x ^ iz.z.x;
endmodule
