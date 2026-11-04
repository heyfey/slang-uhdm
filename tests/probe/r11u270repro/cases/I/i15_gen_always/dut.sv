// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
module top(input int w, output logic y);
  import up::*;
  if (1) begin : g
    always_comb y = w inside {UVM_SET, UVM_GET};
  end
endmodule
