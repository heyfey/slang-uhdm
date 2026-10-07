// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
module top;
  import up::*;
  task automatic t(int w);
    while (w inside {UVM_SET, UVM_GET}) w = w + 1;
  endtask
endmodule
