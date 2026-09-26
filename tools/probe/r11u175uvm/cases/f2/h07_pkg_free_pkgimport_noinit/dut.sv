package p1;
  function automatic int f(int a);
    int arr[$];
    int id;
    arr.push_back(a);
    id = a;
    return id;
  endfunction
endpackage
package p2;
  import p1::*;
  int k;
endpackage
module top;
  import p2::*;
  initial k = 1;
endmodule
