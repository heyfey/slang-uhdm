// § methCallNameSpanAcrossLines244
package p;
  class c;
    function int get(); return 1; endfunction
    function int h(int a); return a; endfunction
    c nx;
  endclass
  class d #(int W = 2);
    c m;
    function void run();
      int z;
      bit [W-1:0] q;
      z = this.m.
            get();
      z = m .
          h(.a(m.
                get()));
      z = m.nx
            .get();
    endfunction
  endclass
endpackage
module top;
  p::d #(4) dd;
endmodule
