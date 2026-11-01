// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
parameter int unsigned N = $bits(s) - 1; parameter logic [7:0] K = $bits(s); parameter N2 = $bits(s); endpackage
module top; import p::*; logic [7:0] y, z, w; assign y = N; assign z = K; assign w = N2; endmodule
