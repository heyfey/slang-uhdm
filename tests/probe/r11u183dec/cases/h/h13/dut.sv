package p;
  string ver;
endpackage
module top;
  import p::*;
  string s;
  initial s = ver;
endmodule
