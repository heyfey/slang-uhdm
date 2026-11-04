// § pkgQualFoldSpanByView124
package bp; localparam logic [1:0] BASE = 2'b00; localparam logic [1:0] USAGE = BASE | 2'b01; endpackage
module top (); localparam logic [1:0] P = bp::USAGE; endmodule
