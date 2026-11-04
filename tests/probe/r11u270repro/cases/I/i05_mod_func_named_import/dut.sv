// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
module top;
  import up::UVM_SET;
  import up::UVM_GET;
  function automatic void auto(int w);
    if (w inside {UVM_SET, UVM_GET}) w = 0;
  endfunction
endmodule
