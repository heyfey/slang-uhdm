// § insideSetParamFoldKeepsPa270
package up;
  parameter UVM_SET = 32'h1;
  parameter UVM_GET = 32'h2;
endpackage
module top(input int w, output logic y);
  import up::*;
  always_comb case (w) inside
    UVM_SET: y = 1;
    UVM_GET, 5: y = 0;
    default: y = 0;
  endcase
endmodule
