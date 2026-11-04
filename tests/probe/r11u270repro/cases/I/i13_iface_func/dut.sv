// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
interface ifc;
  import up::*;
  function automatic bit f(int w);
    return w inside {UVM_SET, UVM_GET};
  endfunction
endinterface
module top;
  ifc i();
endmodule
