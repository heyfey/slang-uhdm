// § pkgQualFoldSpanByView124
package bp; localparam logic [1:0] BASE = 2'b00; localparam logic [1:0] USAGE = BASE | 2'b01; endpackage
package ep; localparam FROM_USAGE = bp::USAGE; endpackage
module top import ep::*; #() (); endmodule
