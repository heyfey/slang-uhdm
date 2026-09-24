// § aggArrayOuterRangeLoc124
package q; typedef struct packed { logic [1:0] x; } a; endpackage
package pkg; typedef q::a [2:0] b; endpackage
module top(output pkg::b o); assign o = '0; endmodule
