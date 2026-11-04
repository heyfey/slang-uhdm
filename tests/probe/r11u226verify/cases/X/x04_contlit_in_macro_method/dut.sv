// § strLitContLineSpan220 § ppDotNameAfterArgToken219 § ppIdentEndInRebuiltText219 — a continued string literal passed with a method call on a forwarded actual through two macros
`define SAY(O,S) $display("%s %s", O.get_name(), S)
`define SAY2(O,S) \
  begin \
    `SAY(O,S); \
  end
package p;
class n_c;
  function string get_name(); return "n"; endfunction
endclass
class user_c;
  n_c h;
  function void run();
    `SAY2(h, "cont \
lit")
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
