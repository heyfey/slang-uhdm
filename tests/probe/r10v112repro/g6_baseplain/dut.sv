// g6 — THE ASCII-FIRST MEMBER CARRIES NO ARGUMENTS AT ALL (it takes the
// generic's defaults).  base->Parameters() is then empty on our side and the
// copy refuses; what does golden bind the other two to?
package p6box;
  class B6 #(type Q = int, string Nm = "?"); int x6; endclass
endpackage
package p6use;
  import p6box::*;
  class Aaa6; typedef B6 t6;                  endclass
  class bbb6; typedef B6 #(bbb6,"bbb6") t6;   endclass
  class ccc6; typedef B6 #(ccc6,"ccc6") t6;   endclass
endpackage
