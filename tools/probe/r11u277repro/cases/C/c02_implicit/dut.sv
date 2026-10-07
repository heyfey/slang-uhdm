// § ctorRetVarSiblingSpan277
package p;
  class b1;
    function new(input a);
    endfunction
  endclass
  class b2;
    function new(a);
    endfunction
  endclass
  class b3;
    function new(input [3:0] a);
    endfunction
  endclass
  class b4;
    function new(input signed [3:0] a);
    endfunction
  endclass
  class b6;
    function new([7:0] a);
    endfunction
  endclass
  class b7;
    function new(input   a  =  1);
    endfunction
  endclass
  class b8;
    function new(ref a);
    endfunction
  endclass
endpackage
module top;
  p::b1 x;
endmodule
