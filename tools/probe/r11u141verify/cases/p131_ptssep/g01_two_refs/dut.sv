// § pkgParamTsRefColons131
// case g01: a package parameter whose range bound references two package parameters
package pk;
  parameter int A = 2;
  parameter int B = 3;
  parameter logic [A+B-1:0] P = '1;
endpackage
module top(output logic [4:0] o);
  assign o = pk::P;
endmodule
