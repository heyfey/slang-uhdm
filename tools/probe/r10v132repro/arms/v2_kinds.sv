`include "v_defs.svh"
package pkg_v2132;
  class cls_v2132;
    string qprop132[$];
    int aprop132[string];
    int szv132;
    cls_v2132 self132;
    function void v132_user(string s);
    endfunction
    function void m_local132();
      string qloc132[$];
      `V_PASTE(QUEUE, qprop132)
      `V_PASTE(QUEUE, qloc132)
      `V_APASTE(ASSOC, aprop132, "k")
      `V_UPASTE(USER, self132, "z")
    endfunction
    function void m_formal132(ref string qref132[$]);
      `V_PASTE(QUEUE, qref132)
    endfunction
  endclass
  string qpkg132[$];
  function void f_pkg132();
    `V_PASTE(QUEUE, qpkg132)
  endfunction
endpackage
module top_v2132;
  import pkg_v2132::*;
  string qmod132[$];
  initial begin
    `V_PASTE(QUEUE, qmod132)
  end
  always @(*) begin
    `V_PASTE2(QUEUE, qmod132, "y")
  end
endmodule
