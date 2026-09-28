// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = int);
    localparam type L = T;
    parameter type B = byte;
    T p;
    B bp;
    L lp;
    function void f(B x, L y);
      bp = x; lp = y;
    endfunction
  endclass
endpackage
module top; endmodule
