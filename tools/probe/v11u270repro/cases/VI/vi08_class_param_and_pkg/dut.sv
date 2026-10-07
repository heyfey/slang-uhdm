// § insideSetParamFoldKeepsPa270
package up;
  parameter int A = 1;
  parameter int B = 2;
endpackage
package cp;
  import up::*;
  class base #(int A = 10);
    function bit f(int w);
      return w inside {A, B};
    endfunction
  endclass
  class d extends base #(3);
    function bit g(int w);
      return w inside {A, B};
    endfunction
  endclass
endpackage
module top;
  import cp::*;
  d x;
endmodule
