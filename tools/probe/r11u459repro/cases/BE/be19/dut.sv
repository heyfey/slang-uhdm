// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [7:0] a; e b;} s; typedef s arr_t [3]; parameter int N = $bits(arr_t); parameter int W = $bits(s) > 8 ? 1 : 2; endpackage
module top; import p::*; endmodule
