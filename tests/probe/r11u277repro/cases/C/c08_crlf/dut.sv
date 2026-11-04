// § ctorRetVarSiblingSpan277
package p;
  class base;
    function new(string name = "");
    endfunction
  endclass
  class a1 extends base;
    function new(input string name = "a1");
      super.new(name);
    endfunction
  endclass
  class a2;
    function new(output int o);
    endfunction
  endclass
  class a3;
    function new(inout int io);
    endfunction
  endclass
  class a4;
    function new(ref int r);
    endfunction
  endclass
  class a5;
    function new(const ref int cr);
    endfunction
  endclass
  class a8;
    function new(int a, input string b);
    endfunction
  endclass
  class a9;
    function new(input int a, b);
    endfunction
  endclass
endpackage
module top;
  p::a1 x;
endmodule
