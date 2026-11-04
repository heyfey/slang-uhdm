// § tfItemInitLocalAtType209: locals with initializers in an in-body method
package p;
  class k;
    static function k get(); return null; endfunction
  endclass
  class c;
    function void f;
      static bit first = 1;
      int n = 3;
      k h = k::get();
      int m;
      if (first) m = n;
    endfunction
  endclass
endpackage
module top;
endmodule
