// § shareDefParamTsOwnNotImport262 (interface parameter shadowing a package parameter)
package fp;
  localparam int K = 5;
endpackage
interface ifc import fp::*; #(parameter int K = 2) ();
  logic [K-1:0] s;
endinterface
module top(output logic [1:0] q);
  ifc i();
  assign q = i.s;
endmodule
