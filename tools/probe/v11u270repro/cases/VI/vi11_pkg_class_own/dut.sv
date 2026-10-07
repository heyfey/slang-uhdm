// § insideSetParamFoldKeepsPa270
package up;
  parameter int A = 1;
  parameter int B = 2;
  class c;
    function bit f(int w);
      return w inside {A, B};
    endfunction
  endclass
  function automatic bit g(int w);
    return w inside {A, B};
  endfunction
endpackage
module top;
  import up::*;
  c x;
  bit r;
  initial r = g(3);
endmodule
