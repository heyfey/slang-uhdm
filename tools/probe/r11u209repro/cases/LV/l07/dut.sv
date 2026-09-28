// § tfItemInitLocalAtType209: a class method without parentheses, class-typed and parameterized locals
package p;
  class k #(int W = 1);
    static function k #(W) get(); return null; endfunction
  endclass
  class c;
    function void f;
      k #(2) h2 = null;
      k h1 = null;
      string s = "a";
      real rr = 1.5;
    endfunction
  endclass
endpackage
module top;
endmodule
