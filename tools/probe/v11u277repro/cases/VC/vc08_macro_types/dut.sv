// § ctorRetVarSiblingSpan277
`define T string
`define VEC(n) logic [n-1:0]
`define IN input
package q;
  class qc;
    typedef int qt;
  endclass
endpackage
package p;
  class h1;
    function new(input `T s);
    endfunction
  endclass
  class h2;
    function new(input `VEC(4) v);
    endfunction
  endclass
  class h3;
    function new(`IN `VEC(2) v, int k);
    endfunction
  endclass
  class h4;
    function new(input q::qc::qt t);
    endfunction
  endclass
  class h5;
    function new(input q::qc c = null);
    endfunction
  endclass
endpackage
module top;
  p::h1 x;
endmodule
