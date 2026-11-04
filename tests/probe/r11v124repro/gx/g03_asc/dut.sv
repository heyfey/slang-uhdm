// § aggArrayOuterRangeLoc124
package pkg; typedef struct packed { logic x; } a; typedef a [0:5] b; endpackage
module top(output pkg::b o); assign o = '0; endmodule
