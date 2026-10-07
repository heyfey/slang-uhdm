// § ctorRetVarSiblingSpan277
package q;
  typedef logic [3:0] t;
endpackage
package p;
  class base; endclass
  typedef int myint;
  class k1;
    function new(input logic [3:0] a);
    endfunction
  endclass
  class k2;
    function new(input base b);
    endfunction
  endclass
  class k3;
    function new(input q::t x);
    endfunction
  endclass
  class k4;
    function new(input myint m);
    endfunction
  endclass
  class k5 #(type T = int);
    function new(input T v);
    endfunction
  endclass
  class k6;
    function new(input bit unsigned [1:0] u, int z);
    endfunction
  endclass
  class k7;
    function new(
      input
        string
          s = "x");
    endfunction
  endclass
  class k8;
    function new(input int arr[2]);
    endfunction
  endclass
  class k9;
    function new();
    endfunction
  endclass
  class k10;
    function new;
    endfunction
  endclass
endpackage
module top;
  p::k1 x;
  p::k5 #(byte) y;
endmodule
