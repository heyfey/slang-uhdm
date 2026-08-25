`include "v_defs.svh"
`define V7_QN qname132
`define V_QUEUE_THREE(ARG,VAL) \
  ARG.push_back(VAL); \
  szv7132 = ARG.size(); \

`define V7_PASTE3(TYPE,ARG) \
  begin \
    `V_``TYPE``_THREE(ARG,"z") \
  end \

package pkg_v7132;
  class mid_v7132;
    string q3_132[$];
  endclass
  class inner_v7132;
    mid_v7132 m_v7132;
  endclass
  class cls_v7132;
    inner_v7132 i_v7132;
    string qname132[$];
    int szv7132;
    function void run_v7132();
      // a THREE-component receiver through a paste
      `V7_PASTE3(QUEUE, i_v7132.m_v7132.q3_132)
      // the macro ARGUMENT is itself a MACRO
      `V_PASTE(QUEUE, `V7_QN)
    endfunction
  endclass
endpackage
module top_v7132;
  import pkg_v7132::*;
  cls_v7132 c_v7132;
  initial begin
    c_v7132 = new();
    c_v7132.run_v7132();
  end
endmodule
