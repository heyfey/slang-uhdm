package p1;
  class base;
    int q;
    function void print();
      int arr[$];
      bit b;
      begin
        int loc[$];
        base h;
        loc.push_back(q);
      end
    endfunction
  endclass
endpackage
package p2;
  import p1::*;
  class derived extends base;
    function void g();
      base x;
      x = new;
    endfunction
  endclass
endpackage
module top;
  import p2::*;
  derived d;
  initial begin d = new; d.print(); end
endmodule
