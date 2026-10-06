// § cloneTdSpecDeepCopy269
package bp;
  class reg_c #(type T = int); T m; endclass
endpackage
package up;
  import bp::*;
  class c1; typedef reg_c #(logic [7:0]) tid; endclass
  class c2; typedef reg_c #(bit [3:0][1:0]) tid; endclass
endpackage
module top; endmodule
