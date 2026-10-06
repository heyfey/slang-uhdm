// § tpUseSharesOwnTs271
`define DECL(ty, nm) ty nm;
`define FN(ty) function ty getx(ty a); return a; endfunction
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, string Tname = "<unknown>");
    `DECL(T, mm)
    `FN(T)
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
