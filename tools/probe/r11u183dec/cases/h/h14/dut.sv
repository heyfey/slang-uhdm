package p;
  class c; endclass
  c h = null;
endpackage
module top;
  import p::*;
  c k;
  initial k = h;
endmodule
