// § aggArrayOuterRangeLoc124
package pkg; typedef union packed { logic [1:0] x; logic [1:0] y; } u; typedef u [1:0][2:0] v; endpackage
module top(output pkg::v o); assign o = '0; endmodule
