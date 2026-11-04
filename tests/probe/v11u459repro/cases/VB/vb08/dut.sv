// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
module top; logic [7:0] y; assign y = $bits(s) + 1; endmodule
