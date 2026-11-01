// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s; parameter s P = '0;
parameter int N = $bits(P); parameter int M = N + 1; endpackage
module top; import p::*; logic [7:0] y; assign y = M; endmodule
