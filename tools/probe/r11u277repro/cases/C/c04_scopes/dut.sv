// § ctorRetVarSiblingSpan277
class u1;
  function new(input string s);
  endfunction
endclass
module top;
  class m1;
    function new(input int a);
    endfunction
  endclass
  class m2;
    function new(int a);
    endfunction
  endclass
  m1 x;
  u1 y;
endmodule
program pr;
  class r1;
    function new(input string s);
    endfunction
  endclass
endprogram
package p;
  class outer;
    class inner;
      function new(input int a);
      endfunction
    endclass
  endclass
endpackage
