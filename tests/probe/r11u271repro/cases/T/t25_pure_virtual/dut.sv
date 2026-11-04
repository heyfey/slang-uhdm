// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  virtual class reg_c #(type T = comp, string Tname = "<unknown>");
    pure virtual function T f(T x);
    T m;
  endclass
endpackage
package sp;
  import up::*;
  class sbase extends comp;
    typedef reg_c #(sbase, "sbase") type_id;
  endclass
endpackage
module top;
  sp::sbase s;
endmodule
