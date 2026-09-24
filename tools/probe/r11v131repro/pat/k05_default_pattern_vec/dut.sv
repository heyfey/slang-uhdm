// § pkgPatReadTsNoParent131
package pk;
  parameter logic [7:0] P = '{default: 1'b1};
endpackage
module top (output logic [7:0] o);
  assign o = pk::P;
endmodule
