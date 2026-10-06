// § cloneTdSpecDeepCopy269 (the bound actual is itself a specialization)
package bp;
  class obj; endclass
  class box #(type E = int); endclass
  class reg_c #(type T = obj); endclass
endpackage
package up;
  import bp::*;
  class c1; typedef reg_c #(box #(c1)) tid; endclass
  class c2; typedef reg_c #(box #(c2)) tid; endclass
endpackage
module top; endmodule
