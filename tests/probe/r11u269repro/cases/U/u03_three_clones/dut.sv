// § cloneTdSpecDeepCopy269 (three members of one group across two packages)
package bp;
  class obj; endclass
  class reg_c #(type T = obj, string N = "?"); endclass
endpackage
package p1;
  import bp::*;
  class c1 extends obj; typedef reg_c #(c1, "c1") type_id; endclass
  class c2 extends obj; typedef reg_c #(c2, "c2") type_id; endclass
endpackage
package p2;
  import bp::*;
  class c3 extends obj; typedef reg_c #(c3, "c3") type_id; endclass
endpackage
module top; endmodule
