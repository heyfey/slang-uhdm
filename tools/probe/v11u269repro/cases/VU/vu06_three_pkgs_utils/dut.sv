// § cloneTdSpecDeepCopy269
`define utils(T) typedef reg_c #(T, `"T`") type_id;
package bp;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, string Tname = "<unknown>"); T m; endclass
  class cmp #(type B = int) extends comp;
    typedef cmp #(B) this_type;
    `utils(this_type)
  endclass
endpackage
package p1;
  import bp::*;
  class a extends comp; `utils(a) endclass
endpackage
package p2;
  import bp::*;
  class b extends comp; `utils(b) endclass
  class c extends cmp #(int); `utils(c) endclass
endpackage
module top; p2::b h; endmodule
