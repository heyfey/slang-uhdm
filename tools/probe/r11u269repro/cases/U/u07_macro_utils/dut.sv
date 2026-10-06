// § cloneTdSpecDeepCopy269 (the typedef written by a macro, as uvm_component_utils does)
`define UTILS(T) typedef reg_c #(T, `"T`") type_id;
package bp;
  class obj; endclass
  class reg_c #(type T = obj, string Tname = "<unknown>"); endclass
endpackage
package up;
  import bp::*;
  class c1 extends obj; `UTILS(c1) endclass
  class c2 extends obj; `UTILS(c2) endclass
  class pc #(type B = int) extends obj;
    typedef pc #(B) this_type;
    `UTILS(this_type)
  endclass
endpackage
module top; endmodule
