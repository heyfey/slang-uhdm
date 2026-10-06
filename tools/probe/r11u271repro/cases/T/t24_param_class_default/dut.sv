// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class holder #(type P = int) extends comp; endclass
  class reg_c #(type T = holder#(int), string Tname = "<unknown>");
    T m;
    function T g();
      T o;
      return o;
    endfunction
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
