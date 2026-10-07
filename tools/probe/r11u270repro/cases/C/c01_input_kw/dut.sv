// § insideSetParamFoldKeepsPa270
package p;
  class base;
    function new(string name = "");
    endfunction
  endclass
  class d1 extends base;
    function new(input string name = "d1");
      super.new(name);
    endfunction
  endclass
  class d2 extends base;
    function new(string name = "d2");
      super.new(name);
    endfunction
  endclass
  class d3;
    function new(input int a, input string b);
    endfunction
  endclass
  class d4;
    function new(input a);
    endfunction
  endclass
endpackage
module top;
  p::d1 x;
endmodule
