// § pkgPatReadTsNoParent131
package p; typedef struct { int unsigned C; int unsigned D; } b_t; localparam b_t B = '{C:0, D:8}; endpackage
module top(output logic [7:0] o); import p::*; assign o = B.D; endmodule
