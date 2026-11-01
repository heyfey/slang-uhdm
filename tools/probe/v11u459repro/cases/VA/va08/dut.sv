// § defFlipUnszBasedRaw459
package p; parameter logic [9:0] D = 'b11; endpackage
interface ifc #(W=2); import p::*; logic [W-1:0] s; endinterface
module top; ifc #(3) a(); ifc #(4) b(); endmodule
