// § cloneTdSpecDeepCopy269
package bp;
  class reg_c #(type T = int); endclass
  class base #(type D = int); typedef reg_c #(D) tid; endclass
endpackage
package up;
  import bp::*;
  class d1 extends base #(d1); endclass
  class d2 extends base #(d2); typedef reg_c #(base #(d2)) tid2; endclass
endpackage
module top; endmodule
