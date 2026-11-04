// § ppDotNameAfterArgToken219 — a member call on a multi-token actual `this.h` inside a nested multi-line message macro
`define SHOW(ID,MSG) \
   begin \
     $display("%s %s", ID, MSG); \
   end
`define TR(CB,OPER) \
  begin \
    `SHOW("TRC", $sformatf("%s : %s", \
       OPER, CB.get_name())) \
  end
package p;
class obj_c;
  function string get_name(); return "n"; endfunction
endclass
class user_c;
  obj_c h;
  function void run();
    `TR(this.h, "op")
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
