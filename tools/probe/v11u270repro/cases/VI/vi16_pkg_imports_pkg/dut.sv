// § insideSetParamFoldKeepsPa270
package up;
  parameter int A = 1;
  parameter int B = 2;
endpackage
package q;
  import up::*;
  parameter int C = 3;
  function automatic bit f(int w);
    return w inside {A, B, C};
  endfunction
  class k;
    function bit g(int w); return w inside {A, C}; endfunction
  endclass
endpackage
module top;
  import q::*;
  bit r;
  initial r = f(2);
endmodule
