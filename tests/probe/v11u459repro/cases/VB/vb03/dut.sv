// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef union packed {e a; logic [31:0] b;} u_t;
parameter int N = $bits(u_t); parameter int M = N - 1; endpackage
module top; import p::*; logic [7:0] y; assign y = M; endmodule
