// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, string Tname = "<unknown>");
    T q2[$][2];
    T am[string];
    T am2[int];
    function void f(); T l[$]; T m2[string]; l.push_back(null); endfunction
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
