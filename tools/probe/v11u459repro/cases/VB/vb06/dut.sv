// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef e e2; typedef struct packed {e2 a; logic [5:0] b;} s;
parameter int N = $bits(s); parameter int M = (N + 7) / 8; endpackage
module top; import p::*; logic [7:0] y; assign y = M; endmodule
