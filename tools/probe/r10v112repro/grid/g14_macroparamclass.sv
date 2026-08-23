// g14 — THE SAME MACRO LINE expanded for a PLAIN class and then for a
// PARAMETERIZED class, plus a third plain class, all one foreign generic.
// ASCII: Aa14 < pp14 < zz14, so the base is the plain class Aa14 and the
// parameterized member must take Aa14 too.
`define reg14(T) typedef B14 #(T,"T") t14
package p14box;
  class B14 #(type Q = int, string Nm = "?"); int x14; endclass
endpackage
package p14use;
  import p14box::*;
  class Aa14;                 `reg14(Aa14); endclass
  class pp14 #(type W14 = int); `reg14(W14); endclass
  class zz14;                 `reg14(zz14); endclass
endpackage
module g14top;
  import p14use::*;
  pp14 #(int)  a14;
  pp14 #(byte) b14;
  zz14         c14;
endmodule
