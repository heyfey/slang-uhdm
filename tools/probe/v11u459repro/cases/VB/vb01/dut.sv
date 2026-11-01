// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [7:0] a; e b;} s;
module top; s v; localparam int W = $bits(v); localparam int W2 = W + 2; logic [7:0] y; assign y = W2; endmodule
