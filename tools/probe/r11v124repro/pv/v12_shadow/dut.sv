// § paramValueIsDefRhs124
package p; parameter int X = 4; endpackage
module top import p::*; #(parameter int X = 7) (output int o); assign o = X; endmodule
