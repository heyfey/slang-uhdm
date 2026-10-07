// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 3; endpackage
interface ifc; parameter K = p::A; logic [K:0] v; assign v = '1; endinterface
module top(output logic [7:0] o);
  ifc u();
  assign o = u.v;
endmodule
