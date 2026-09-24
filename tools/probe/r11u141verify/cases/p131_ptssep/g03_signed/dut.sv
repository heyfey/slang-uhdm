// § pkgParamTsRefColons131
// case g03: a signed package parameter whose range references a package parameter, read via import
package pk;
  parameter int N = 6;
  parameter logic signed [N-1:0] P = -6'sd3;
endpackage
module top(output logic [5:0] o);
  import pk::*;
  assign o = P;
endmodule
