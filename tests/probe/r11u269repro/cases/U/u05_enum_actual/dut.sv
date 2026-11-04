// § cloneTdSpecDeepCopy269 (the bound actual is a package enum typedef)
package bp;
  typedef enum logic [1:0] { E0, E1 } e_t;
  class reg_c #(type T = int); endclass
endpackage
package up;
  import bp::*;
  class c1; typedef reg_c #(e_t) tid; endclass
  class c2; typedef reg_c #(c2) tid; endclass
endpackage
module top; endmodule
