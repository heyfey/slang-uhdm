// r11u218 decode (no law written; the face named macroArgMethodCallSpan218 in the README) — k03_arg_call: a call written in a macro argument used inside the body as an argument (the uvm_info MSG shape)
`define INFO(ID, MSG) \
   begin \
     rep(ID, \
         MSG); \
   end
package p;
  class d;
    function string get_full_name();
      return "x";
    endfunction
    function void rep(string a, string b);
    endfunction
    function void run();
      `INFO("id", get_full_name())
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
