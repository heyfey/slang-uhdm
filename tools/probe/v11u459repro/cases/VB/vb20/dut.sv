// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
parameter int N = $bits(s); endpackage
package q; import p::*; parameter int M = N + 8; typedef bit [M-1:0] m_t; endpackage
module top; import q::*; m_t a; logic [7:0] y; assign y = M; endmodule
