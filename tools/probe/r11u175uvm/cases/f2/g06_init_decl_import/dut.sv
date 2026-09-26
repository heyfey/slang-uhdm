package p1;
  class base;
    extern function void print(int all = 1);
  endclass
  function void base::print(int all = 1);
    base h = new;
    int id = all;
    string s;
    id = all + 1;
    s = "x";
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
