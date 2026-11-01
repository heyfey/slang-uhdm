// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
module top; localparam int W = $bits(s); logic [W-1:0] x; assign x = '0; endmodule
