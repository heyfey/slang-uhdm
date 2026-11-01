// § pkgBitsTypeEnumZero459
package p; typedef struct packed {enum {X,Y} k; logic [3:0] d;} s;
parameter int N = $bits(s); parameter int M = N + 4; endpackage
module top; import p::*; logic [7:0] y; assign y = M; endmodule
