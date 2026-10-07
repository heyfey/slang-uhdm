// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
module top;
  import up::*;
  function automatic void auto(int w);
    if (w == UVM_SET || w != UVM_GET) w = 0;
  endfunction
endmodule
