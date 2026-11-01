// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct packed {logic [7:0] a; e b;} s; parameter int N = $bits(s); parameter int M = (N+7)/8; typedef bit [N-1:0] v_t; endpackage
package q; import p::*; class C; endclass endpackage
import p::*;
module m(); import p::*; endmodule
import p::*; import q::*;
interface ifc(); endinterface
package r; import q::*; endpackage
module top; import r::*; m u(); ifc i(); endmodule
