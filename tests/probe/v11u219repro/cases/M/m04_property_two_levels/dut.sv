// § ppDotNameAfterArgToken219 — a PROPERTY (not a call) of an actual, `CB.name`, forwarded through two multi-line macros, next to a call on the same actual
`define SHOW(MSG) \
   begin \
     $display("%s", MSG); \
   end
`define TR2(CB) \
  begin \
    `SHOW($sformatf("%s %0d", \
       CB.name, CB.cnt())) \
  end
`define TR1(CB) \
  `TR2(CB)
package p;
class obj_c;
  string name;
  function int cnt(); return 1; endfunction
endclass
class user_c;
  obj_c o;
  function void run();
    `TR1(o)
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
