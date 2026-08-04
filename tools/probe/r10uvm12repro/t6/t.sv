package p;
  class base;
    function void bm(int a);
    endfunction
    extern function void xm(int a);
  endclass
  function void base::xm(int a);
  endfunction
  class mid extends base;
    function void go();
      bm(1);
      xm(2);
    endfunction
  endclass
  class gmid #(type T = int) extends base;
    function void go();
      bm(3);
      xm(4);
    endfunction
  endclass
  class useg;
    gmid#(int) g;
    function void go();
      g.go();
    endfunction
  endclass
endpackage

module top;
  import p::*;
  mid m;
  initial m.go();
endmodule
