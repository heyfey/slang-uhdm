// § cloneTdSpecDeepCopy269 (the base binds a builtin type: the clone copies the int_typespec)
package bp;
  class box #(type Q = int); Q v; endclass
endpackage
package up;
  import bp::*;
  class a1; typedef box #(a1) tid; endclass
  class z9; typedef box #(int) tid; endclass
endpackage
module top; endmodule
