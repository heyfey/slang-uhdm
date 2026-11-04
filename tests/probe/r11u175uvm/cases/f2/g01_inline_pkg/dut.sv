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
module top;
  import p1::*;
  base b;
  initial begin b = new; b.print(); end
endmodule
