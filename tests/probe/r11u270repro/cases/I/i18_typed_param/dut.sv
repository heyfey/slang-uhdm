// § insideSetParamFoldKeepsPa270
package up;
  parameter int UVM_SET = 1;
  parameter bit [3:0] UVM_GET = 4'h2;
  localparam logic [7:0] L = 8'd9;
endpackage
module top;
  import up::*;
  function automatic void auto(int w);
    if (w inside {UVM_SET, UVM_GET, L}) w = 0;
  endfunction
endmodule
