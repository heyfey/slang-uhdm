package p1;
  class base;
    int q;
    extern function void print(int all = 1);
  endclass
  function void base::print(int all = 1);
    string key;
    int arr[$];
    base h;
    int id;
    arr.push_back(all);
    id = all;
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
