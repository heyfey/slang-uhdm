// § tfItemInitLocalAtType209: locals with initializers in an out-of-body method
package p;
  class k;
    static function k get(); return null; endfunction
  endclass
  class c;
    extern function void f;
  endclass
  function void c::f;
    static bit first = 1;
    int n = 3;
    k h = k::get();
    int m;
    if (first) m = n;
  endfunction
endpackage
module top;
endmodule
