// § classTpKeywordTsAtDefault188
package p;
  class base #(type T = int);
    T bp;
    function void bset(T x); bp = x; endfunction
  endclass
  class der #(type T = int) extends base #(T);
    T dp;
    function void dset(T y); dp = y; endfunction
  endclass
  der h;
endpackage
module top; endmodule
