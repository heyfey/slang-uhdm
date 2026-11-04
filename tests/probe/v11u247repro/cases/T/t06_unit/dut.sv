// § clsTpKwDefaultArrElemAtUse247
class uq #(type T=int);
  T a[$];
  T f[2][3];
  function void put(T x); endfunction
endclass
module top;
  uq x;
endmodule
