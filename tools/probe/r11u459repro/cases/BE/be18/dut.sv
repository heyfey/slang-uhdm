// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [7:0] a; e b;} s; s v; parameter int N = $bits(v); parameter int Q = $bits(e) + 4; parameter int U = -$bits(s); endpackage
module top; import p::*; endmodule
