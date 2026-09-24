// § pkgPatReadTsNoParent131
package p; typedef struct packed { logic [1:0] a; logic b; } s_t; parameter s_t P = '{a: 2'b10, b: 1'b1}; endpackage
interface ifc; import p::*; s_t v; endinterface
module top(output logic o); ifc i(); assign o = i.v.b; endmodule
