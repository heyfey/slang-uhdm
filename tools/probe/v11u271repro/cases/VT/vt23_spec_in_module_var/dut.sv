// § tpUseSharesOwnTs271
package up;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp, string Tname = "<unknown>");
    T m;
    static function T create(); T r; return r; endfunction
  endclass
endpackage
module top;
  import up::*;
  reg_c #(comp, "x") h;
  reg_c #(obj) h2;
  comp c;
  initial c = reg_c#(comp)::create();
endmodule
