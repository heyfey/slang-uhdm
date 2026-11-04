// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [7:0] a; e b;} s; parameter int N = $bits(s); parameter int M = (N+7)/8; endpackage
import p::*;
package q; import p::*; endpackage
module top; import q::*; endmodule
