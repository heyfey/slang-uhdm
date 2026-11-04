// § tfBodyTypedefForcesBegin304
package p;
  class c #(int W = 2);
    int m;
    function void g(int a);
      typedef bit [W-1:0] s_t;
      m = a;
    endfunction
  endclass
endpackage
module top; p::c #(4) h; initial begin h = new; h.g(1); end endmodule
