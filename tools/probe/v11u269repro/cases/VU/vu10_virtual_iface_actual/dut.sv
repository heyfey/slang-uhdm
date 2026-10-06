// § cloneTdSpecDeepCopy269
interface ifc; logic a; endinterface
package bp;
  class reg_c #(type T = int); endclass
endpackage
package up;
  import bp::*;
  class c1; typedef reg_c #(virtual ifc) tid; endclass
  class c2; typedef reg_c #(c2) tid; endclass
endpackage
module top; ifc i(); endmodule
