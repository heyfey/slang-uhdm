// § ctorRetVarSiblingSpan277
package p;
  class base; endclass
  class pc #(type T = int); endclass
  class d1;
    function new(input int unsigned a);
    endfunction
  endclass
  class d2;
    function new(input logic signed [3:0] a);
    endfunction
  endclass
  class d3;
    function new(input integer a);
    endfunction
  endclass
  class d4;
    function new(input pc#(byte) h);
    endfunction
  endclass
  class d5;
    function new(input pc #(.T(shortint)) h);
    endfunction
  endclass
  class d6;
    function new(input string s[]);
    endfunction
  endclass
  class d7;
    function new(input string s[$]);
    endfunction
  endclass
  class d8;
    function new(ref string s);
    endfunction
  endclass
  class d9;
    function new(output base b, input int x);
    endfunction
  endclass
endpackage
module top;
  p::d1 x;
endmodule
