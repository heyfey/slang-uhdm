// § ppIdentEndInRebuiltText219 § ppDotNameAfterArgToken219 — one multi-line macro level, the method-call actual starting on the line after the macro name
`define ONLY(CB,M) \
  begin \
    CB.M; \
  end
package p;
class cb_c;
  function void set_mode(int a); endfunction
  function string get_name(); return "x"; endfunction
endclass
class user_c;
  cb_c cb;
  function void run(int x);
    `ONLY(
      cb, set_mode(x))
    $display("%s", cb.get_name());
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
