// § externProtoFormalsFromPrototype175
package p;
  class c #(type T = int, int N = 3);
    extern function T get(T a [N], int i = N - 1);
  endclass
  function c::T c::get(T a [N], int i = N - 1);
    return a[i];
  endfunction
endpackage
module top;
  import p::*;
  c #(byte, 4) o; byte arr [4]; byte r;
  initial begin o = new; r = o.get(arr); end
endmodule
