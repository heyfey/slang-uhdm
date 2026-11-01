// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
parameter int N = $bits(s) << 1; parameter int M = $clog2($bits(s)); endpackage
module top; import p::*; logic [7:0] y, z; assign y = N; assign z = M; endmodule
