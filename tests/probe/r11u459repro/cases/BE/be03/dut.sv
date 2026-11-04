// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; parameter int N = $bits(e); endpackage
module top; import p::*; endmodule
