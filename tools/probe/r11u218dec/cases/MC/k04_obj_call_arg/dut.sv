// r11u218 decode (no law written; the face named macroArgMethodCallSpan218 in the README) — k04_obj_call_arg: an object method call written in a macro argument used inside the body
`define INFO(ID, MSG) \
   begin \
     rep(ID, MSG); \
   end
package p;
  class d;
    function string get_full_name();
      return "x";
    endfunction
    function void rep(string a, string b);
    endfunction
  endclass
  class e;
    d o;
    function void run();
      `INFO("id", o.get_full_name())
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
