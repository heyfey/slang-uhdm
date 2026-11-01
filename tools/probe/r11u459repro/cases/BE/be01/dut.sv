// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [7:0] a; e b;} s; parameter int N = $bits(s); endpackage
module top; import p::*; endmodule
