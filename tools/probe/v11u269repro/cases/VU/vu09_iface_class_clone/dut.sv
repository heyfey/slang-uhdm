// § cloneTdSpecDeepCopy269
package bp;
  class obj; endclass
  class reg_c #(type T = obj, type U = T); endclass
endpackage
package up;
  import bp::*;
  class c1 extends obj; typedef reg_c #(c1) tid; endclass
  class c2 extends obj; typedef reg_c #(c2, c1) tid; endclass
  class c3 extends obj; typedef reg_c #(c3) tid; endclass
endpackage
module top; endmodule
