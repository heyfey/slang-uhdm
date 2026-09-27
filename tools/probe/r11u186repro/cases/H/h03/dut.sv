// § importNetTsToInitEnd183 (controls: no initializer, a class handle)
package p;
  class c; endclass
  int plain;
  c h = null;
endpackage
module top;
  import p::*;
  int s;
  initial s = plain;
endmodule
