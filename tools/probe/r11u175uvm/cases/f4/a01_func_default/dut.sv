package p1;
  class base;
    extern function void print(int all = 1);
  endclass
  function void base::print(int all = 1);
    int id;
    id = all;
  endfunction
endpackage
module top;
  import p1::*;
  base b;
  initial begin b = new; b.print(); end
endmodule
