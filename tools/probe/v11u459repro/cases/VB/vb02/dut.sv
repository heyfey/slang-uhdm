// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [7:0] a; e b;} s; typedef s arr_t [2];
parameter int N = $bits(arr_t); parameter int M = N + 1; endpackage
module top; import p::*; logic [7:0] y; assign y = M; endmodule
