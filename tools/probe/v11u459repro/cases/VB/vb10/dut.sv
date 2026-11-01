// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
class C; localparam int N = $bits(s); localparam int M = N + 1; int v = M; endclass endpackage
module top; import p::*; C c; endmodule
