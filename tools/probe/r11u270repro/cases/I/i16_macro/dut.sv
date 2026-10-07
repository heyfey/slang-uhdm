// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
`define AUTO(W) if (W inside {UVM_SET, UVM_GET}) W = 0;
package vp;
  import up::*;
  class item;
    function void auto(int what__);
      `AUTO(what__)
    endfunction
  endclass
endpackage
module top;
  vp::item i;
endmodule
