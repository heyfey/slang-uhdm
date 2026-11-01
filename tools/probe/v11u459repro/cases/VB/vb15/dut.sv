// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b; struct packed {e c; logic [1:0] d;} n;} s;
parameter int N = $bits(s); endpackage
module top; import p::*; logic [7:0] y; assign y = N; endmodule
