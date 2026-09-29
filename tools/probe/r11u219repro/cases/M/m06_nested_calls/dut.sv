// § ppDotNameAfterArgToken219 — nested calls and a method chain in a macro argument after a multi-line trace, the object an actual
`define INFO(ID,MSG) \
   begin \
     if (1) \
       $display("%s %s", ID, MSG); \
   end
`define TRACE(CB,OPER) \
  begin \
    `INFO("TRC", $sformatf("%s : %s %0d" ,  \
       OPER, CB.get_name(), CB.id().get_id())) \
  end
`define DO(CB,METHOD) \
   begin \
     `TRACE(CB, $sformatf(`"method 'METHOD' on CB`")) \
     CB.METHOD; \
   end
package p;
class k; function int get_id(); return 1; endfunction endclass
class c;
  k kk;
  function string get_name(); return "n"; endfunction
  function k id(); return kk; endfunction
  function int f(int a); return a; endfunction
  function void g(int a, int b); endfunction
  function void run(c cb, int x);
    `DO(cb, g(f(x), cb.id().get_id()))
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
