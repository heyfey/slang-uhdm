// § cloneTdSpecDeepCopy269
package bp;
  typedef struct packed { logic [3:0] a; logic b; } st_t;
  class reg_c #(type T = int); T m; endclass
endpackage
package up;
  import bp::*;
  class c1; typedef reg_c #(st_t) tid; endclass
  class c2; typedef reg_c #(c2) tid; endclass
  class c3; typedef reg_c #(c3) tid; endclass
endpackage
module top; endmodule
