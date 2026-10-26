// § unitParamNameBindsDesign431
package p; localparam CF = 2; endpackage
import p::*;
module top(input [3:0] c, output logic y);
localparam CF = 1;
always_comb y = c[CF];
endmodule
