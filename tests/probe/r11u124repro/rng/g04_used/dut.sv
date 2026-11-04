// § aggArrayOuterRangeLoc124
package pkg; typedef struct packed { logic x; } a; typedef a[5:0] b; endpackage
module top(input pkg::b i, output pkg::b o); assign o = i; endmodule
