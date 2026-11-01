// § pkgBitsTypeEnumZero459
package p; typedef enum {A,B} e; typedef struct {e a; logic [7:0] b;} us;
parameter int N = $bits(us); parameter int M = N * 3; endpackage
module top; import p::*; logic [7:0] y; assign y = M; endmodule
