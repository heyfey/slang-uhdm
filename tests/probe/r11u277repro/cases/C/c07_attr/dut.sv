// § ctorRetVarSiblingSpan277
package p;
  class t1;
    function new((* keep *) input int a);
    endfunction
  endclass
  class t2;
    function new((* keep *) int a);
    endfunction
  endclass
  class t3;
    function new(input /* c */ string s);
    endfunction
  endclass
endpackage
module top;
  p::t1 x;
endmodule
