// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
function automatic int f(); return $bits(s) * 2; endfunction endpackage
module top; import p::*; int y; initial y = f(); endmodule
