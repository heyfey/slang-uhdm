// § ppDotNameAfterArgToken219 — a member call on an actual ending in a bracket, `CB.get_name()` with CB = `objs[0]`, through a second multi-line macro
`define SHOW(ID,MSG) \
   begin \
     $display("%s %s", ID, MSG); \
   end
`define TR(CB) \
  begin \
    `SHOW("TRC", $sformatf("%s %0d", \
       CB.get_name(), 1)) \
  end
package p;
class obj_c;
  function string get_name(); return "n"; endfunction
endclass
class user_c;
  obj_c objs[2];
  function void run();
    `TR(objs[0])
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
