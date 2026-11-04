`include "defs.svh"
module top;
  import p::*;
  holder h;
  string loc_q[$];
  initial begin
    `CF_PASTE(QUEUE, loc_q)
    `CF_PASTE(QUEUE, h.q)
  end
endmodule
