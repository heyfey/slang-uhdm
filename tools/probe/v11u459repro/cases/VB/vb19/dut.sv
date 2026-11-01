// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
parameter int N = $bits(s); typedef logic [N-1:0] v_t; typedef logic [N:0][1:0] w_t; endpackage
module top; import p::*; v_t a; w_t b; endmodule
