// § aggArrayOuterRangeLoc124
package pkg; typedef struct packed { logic [1:0] x; } a; typedef a[3:0] b; parameter b P = '0; endpackage
module top(output pkg::b o); assign o = pkg::P; endmodule
