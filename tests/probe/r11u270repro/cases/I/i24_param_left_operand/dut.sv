// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
endpackage
module top;
  import up::*;
  int a, b;
  function automatic bit f(int w);
    return UVM_SET inside {w, 3};
  endfunction
endmodule
