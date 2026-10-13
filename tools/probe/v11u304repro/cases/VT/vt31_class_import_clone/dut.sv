// § tfBodyTypedefIsItem304
package p;
  class c;
    function int m(int a);
      typedef logic [3:0] n_t;
      n_t b;
      b = a;
      return b;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class d extends c; endclass
endpackage
module top; endmodule
