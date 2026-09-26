// § externProtoFormalsFromPrototype175
package p;
  class k #(int N = 4);
    extern function bit [N-1:0] f(bit [N-1:0] a);
  endclass
  function bit [N-1:0] k::f(bit [N-1:0] a);
    return ~a;
  endfunction
endpackage
module top;
  import p::*;
  k #(8) o; bit [7:0] r;
  initial begin o = new; r = o.f(8'h0f); end
endmodule
