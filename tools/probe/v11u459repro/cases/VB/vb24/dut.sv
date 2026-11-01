// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
parameter int N = $bits(s); parameter int M = N + 1; endpackage
module top(input logic [7:0] x, output logic [7:0] y); import p::*; assign y = x + M; endmodule
