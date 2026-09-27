package p;
  function automatic int f(); return 3; endfunction
  int cnt = f();
endpackage
module top;
  import p::*;
  int k;
  initial k = cnt;
endmodule
