// § pkgParamTsRefColons131
// case g02: a package localparam of bit type whose range references a package parameter
package pk;
  parameter int N = 4;
  localparam bit [N:0] P = '0;
endpackage
module top(output logic [4:0] o);
  assign o = pk::P;
endmodule
