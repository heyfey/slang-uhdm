package p;
  int cnt = 3 + 4;
  logic [3:0] lv = 4'h3;
endpackage
module top;
  import p::*;
  int k;
  logic [3:0] j;
  initial begin k = cnt; j = lv; end
endmodule
