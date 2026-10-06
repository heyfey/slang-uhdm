// § cloneTdSpecDeepCopy269
package bp;
  class obj; endclass
  class pc #(type X = int); X v; endclass
  class reg_c #(type T = obj); endclass
endpackage
package up;
  import bp::*;
  class c1; typedef reg_c #(pc #(byte)) tid; endclass
  class c2; typedef reg_c #(pc #(shortint)) tid; endclass
  class c3; typedef reg_c #(c3) tid; endclass
endpackage
module top; endmodule
