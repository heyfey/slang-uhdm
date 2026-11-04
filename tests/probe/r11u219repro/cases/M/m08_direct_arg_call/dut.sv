// § ppDotNameAfterArgToken219 — a method call on an actual inside a message argument, the actual passed directly and through a second macro
`define INFO(ID,MSG) \
   begin \
     if (1) \
       $display("%s %s", ID, \
         MSG); \
   end
`define WHO(OBJ) \
  `INFO("W", $sformatf("%s/%s", OBJ.get_name(), \
      OBJ.get_full_name()))
package p;
class c;
  function string get_name(); return "n"; endfunction
  function string get_full_name(); return "f"; endfunction
  function void run(c o);
    `INFO("A", o.get_name())
    `WHO(o)
    `WHO(this)
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
