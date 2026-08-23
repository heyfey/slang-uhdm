// g9 — THE SAME GROUP WITH INSTANCES: 0, 1 and 3 handles of the three member
// classes, to prove the member count (and therefore the base) does not follow
// how many times a class is used.
package p9box;
  class B9 #(type Q = int, string Nm = "?"); int x9; endclass
endpackage
package p9use;
  import p9box::*;
  class Nn9;  typedef B9 #(Nn9,"Nn9") t9; endclass
  class pp9;  typedef B9 #(pp9,"pp9") t9; endclass
  class qq9;  typedef B9 #(qq9,"qq9") t9; endclass
endpackage
module g9top;
  import p9use::*;
  pp9 h9a;
  qq9 h9b, h9c, h9d;
endmodule
