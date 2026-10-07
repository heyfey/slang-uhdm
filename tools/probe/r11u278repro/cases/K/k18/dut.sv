// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 13; endpackage
interface ifc; parameter K = p::A; endinterface
module m; ifc i(); endmodule
