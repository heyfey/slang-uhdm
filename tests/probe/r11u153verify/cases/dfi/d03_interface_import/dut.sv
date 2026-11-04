// § defaultFillImportCopies145
package pack;
parameter int V[2] = '{default: 9};
endpackage
interface ifc;
import pack::*;
logic a;
endinterface
module top(output logic o);
ifc i();
assign o = i.a;
endmodule
