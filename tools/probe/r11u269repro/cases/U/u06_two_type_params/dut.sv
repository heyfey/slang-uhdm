// § cloneTdSpecDeepCopy269 (two type parameters and a value parameter)
package bp;
  class obj; endclass
  class reg_c #(type T = obj, type U = int, int W = 4); endclass
endpackage
package up;
  import bp::*;
  class c1 extends obj; typedef reg_c #(c1, byte, 3) tid; endclass
  class c2 extends obj; typedef reg_c #(c2, shortint, 5) tid; endclass
endpackage
module top; endmodule
