// § ppIdentEndInRebuiltText219 § ppDotNameAfterArgToken219 — the macros in an included CRLF header, used in a module-scope class and in a module initial block
`include "mac.svh"
module top;
  class obj_c;
    function string get_name(); return "n"; endfunction
    function void poke(int a); endfunction
  endclass
  obj_c ob;
  initial begin
    ob = new;
    `TRM(ob, poke(3))
  end
endmodule
