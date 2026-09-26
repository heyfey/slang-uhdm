package p1;
  class base;
    function void print(int all = 1);
      string key;
      int arr[$];
      int id;
      arr.push_back(all);
      id = all;
    endfunction
  endclass
endpackage
package p2;
  import p1::*;
  int k;
endpackage
module top;
  import p2::*;
  initial k = 1;
endmodule
