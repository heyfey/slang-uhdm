// § implicitPortTsFirstDim257 (a task formal in a package with two packed dimensions, an output)
package p; task automatic t(output [1:0][3:0] y); y = '0; endtask endpackage
module top; endmodule
