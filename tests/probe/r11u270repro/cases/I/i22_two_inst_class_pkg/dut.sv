// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
package vp;
  import up::*;
  class base;
  endclass
  class item extends base;
    int what;
    function void auto(int w);
      what = w inside {UVM_GET} ? 1 : 0;
    endfunction
  endclass
endpackage
module top;
  import vp::*;
  item i;
endmodule
