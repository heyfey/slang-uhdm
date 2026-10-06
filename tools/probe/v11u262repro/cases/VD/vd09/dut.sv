// § shareDefParamTsOwnNotImport262 (body localparam read in an if-generate of an interface)
package rp;
  localparam int K = 2;
endpackage
interface ifc import rp::*; #(parameter bit E = 1) ();
  localparam int K = 2;
  logic [7:0] a;
  logic [1:0] q;
  if (E) begin : g
    assign q = a[K +: 2];
  end
endinterface
module top(output logic [1:0] q);
  ifc i();
  assign q = i.q;
endmodule
