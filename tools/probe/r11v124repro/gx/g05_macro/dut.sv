// § aggArrayOuterRangeLoc124
`define N 6
package pkg; typedef struct packed { logic x; } a; typedef a [`N-1:0] b; endpackage
module top(output pkg::b o); assign o = '0; endmodule
