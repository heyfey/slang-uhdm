// § classTpKeywordTsAtDefault188
package pk;
  class c #(type T = int);
    T p;
    function void set(T x); p = x; endfunction
    function T get(); T v; v = p; return v; endfunction
  endclass
endpackage
module dut;
  import pk::*;
  c #(int) h1;
  c h2;
  initial begin
    h1 = new;
    h1.set(3);
  end
endmodule
