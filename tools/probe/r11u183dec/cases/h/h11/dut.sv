package p;
  const string ver = "v1.0 long text";
endpackage
module top;
  import p::*;
  string s;
  initial s = ver;
endmodule
