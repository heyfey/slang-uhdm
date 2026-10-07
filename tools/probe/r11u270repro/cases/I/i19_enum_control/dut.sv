// § insideSetParamFoldKeepsPa270
package up;
  typedef enum {EA, EB} e_t;
endpackage
module top;
  import up::*;
  function automatic void auto(int w);
    if (w inside {EA, EB}) w = 0;
  endfunction
endmodule
