// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = int, string Tname = "<unknown>");
    T m;
  endclass
endpackage
package sp;
  import up::*;
  class sbase extends comp;
    typedef reg_c #(int, "sbase") type_id;
  endclass
endpackage
module top;
  sp::sbase s;
endmodule
