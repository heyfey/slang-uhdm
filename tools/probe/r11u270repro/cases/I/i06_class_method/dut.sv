// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
package vp;
  import up::*;
  class item;
    function void auto(int w);
      if (w inside {UVM_SET, UVM_GET}) w = 0;
    endfunction
  endclass
endpackage
module top;
  vp::item i;
endmodule
