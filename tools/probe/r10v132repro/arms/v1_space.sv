`include "v_defs.svh"
package pkg_v1132;
  class inner_v1132;
    string qi132[$];
  endclass
  class outer_v1132;
    inner_v1132 h1_v132;
    inner_v1132 h2_v132;
    inner_v1132 h3_v132;
    string qflat132[$];
    function void run_v1132();
      `V_PASTE(QUEUE, qflat132)
      `V_PASTE(QUEUE, h1_v132.qi132)
      `V_PASTE(QUEUE, h2_v132 . qi132)
      `V_PASTE(QUEUE, h3_v132/*cv132*/.qi132)
      `V_TWICE(qflat132)
      `V_DEEP(QUEUE, qflat132)
    endfunction
  endclass
endpackage
module top_v1132;
  import pkg_v1132::*;
  outer_v1132 o_v132;
  initial begin
    o_v132 = new();
    o_v132.run_v1132();
  end
endmodule
