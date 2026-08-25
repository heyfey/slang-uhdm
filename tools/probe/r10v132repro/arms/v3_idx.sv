`include "v_defs.svh"
package pkg_v3132;
  typedef string strq132[$];
  class strm_v3132;
    string qs132[$];
  endclass
  class cls_v3132;
    strm_v3132 m_streams132[string];
    strq132 qofq132[$];
    string qq132[$];
    int szv132;
    function void run_v3132();
      // uvm128's negative control shape, in PLAIN source and inside a PASTE.
      szv132 = m_streams132["a"].qs132.size();
      `V_SPASTE(SEL, m_streams132, "b")
      `V_IPASTE(IDX, qofq132, 0)
      `V_PASTE(QUEUE, qq132)
    endfunction
  endclass
endpackage
module top_v3132;
  import pkg_v3132::*;
  cls_v3132 c_v132;
  initial begin
    c_v132 = new();
    c_v132.run_v3132();
  end
endmodule
