// § clsTpKwDefaultArrElemAtUse247
module top;
  class q #(type T=int);
    T a[$];
    T m[T];
    function void put(T x); endfunction
    function T get(); return a[0]; endfunction
  endclass
  q x;
  q#(shortint) y;
endmodule
