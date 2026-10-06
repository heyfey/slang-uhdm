// § cloneTdSpecDeepCopy269
package bp;
  class pc #(type X = int); X v; endclass
  class reg_c #(type T = int); endclass
endpackage
package up;
  import bp::*;
  class c1; typedef reg_c #(pc #(pc #(pc #(byte)))) tid; endclass
  class c2; typedef reg_c #(c2) tid; endclass
endpackage
module top; endmodule
