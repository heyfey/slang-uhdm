package p;
  string ver = "v1.0";
  int cnt = 3;
endpackage
module top;
  import p::*;
  string s;
  int k;
  initial begin s = ver; k = cnt; end
endmodule
