`include "v_defs.svh"
interface if_v9132;
  string qif132[$];
endinterface
package pkg_v9132;
  typedef struct { string qst132[$]; } st_v9132;
  class cls_v9132;
    static string qstat132[$];
    st_v9132 s_v9132;
    string qml132[$];
    function void run_v9132();
      // a MULTI-LINE macro argument
      `V_PASTE(QUEUE,
               qml132)
      // a STRUCT member receiver
      `V_PASTE(QUEUE, s_v9132.qst132)
      // a STATIC class property, bare
      `V_PASTE(QUEUE, qstat132)
    endfunction
  endclass
endpackage
module top_v9132;
  import pkg_v9132::*;
  if_v9132 iv9();
  initial begin
    `V_PASTE(QUEUE, iv9.qif132)
  end
endmodule
