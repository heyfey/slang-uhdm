// § pkgBitsTypeEnumZero459
package p; typedef enum logic [1:0] {A,B} e; typedef struct packed {logic [7:0] a; e b;} s; parameter int N = $bits(s); parameter int M = (N+7)/8; endpackage
import p::*;
module m(); import p::*; endmodule
module top; m u(); endmodule
