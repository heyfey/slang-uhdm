// § cloneTdSpecDeepCopy269
package bp;
  class reg_c #(type T = int); endclass
  class d #(type X = int);
    typedef d #(X) this_t;
    typedef reg_c #(this_t) tid;
  endclass
endpackage
package up;
  import bp::*;
  class e1 extends d #(byte); typedef reg_c #(e1) tid; endclass
  class e2 extends d #(e1); typedef reg_c #(d #(e2)) tid; endclass
endpackage
module top; up::e2 h; endmodule
