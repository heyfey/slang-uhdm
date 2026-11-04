package p1;
  function automatic int f(int a);
    int arr[$];
    int id;
    arr.push_back(a);
    id = a;
    return id;
  endfunction
endpackage
module top;
  import p1::*;
  int r;
  initial r = f(3);
endmodule
