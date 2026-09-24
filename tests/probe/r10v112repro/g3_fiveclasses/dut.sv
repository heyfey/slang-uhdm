// g3 — FIVE members of one foreign generic, all different arguments, source
// order deliberately scrambled against ASCII order.
// ASCII: Alpha3 < Kilo3 < Zulu3 < bravo3 < mike3.
package p3box;
  class B3 #(type Q = int, string Nm = "?"); int x3; endclass
endpackage
package p3use;
  import p3box::*;
  class mike3;  typedef B3 #(mike3,"mike3")   t3; endclass
  class Zulu3;  typedef B3 #(Zulu3,"Zulu3")   t3; endclass
  class bravo3; typedef B3 #(bravo3,"bravo3") t3; endclass
  class Alpha3; typedef B3 #(Alpha3,"Alpha3") t3; endclass
  class Kilo3;  typedef B3 #(Kilo3,"Kilo3")   t3; endclass
endpackage
