// § aggArrayOuterRangeLoc124
package pkg; parameter int W = 4; typedef struct packed { logic x; } a; typedef a [W-1:0] b; endpackage
module top(output pkg::b o); assign o = '0; endmodule
