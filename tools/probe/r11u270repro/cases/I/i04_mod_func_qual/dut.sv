// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
module top;
  function automatic void auto(int w);
    if (w inside {up::UVM_SET, up::UVM_GET}) w = 0;
  endfunction
endmodule
