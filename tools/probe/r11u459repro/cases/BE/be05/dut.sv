// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [7:0] a; e b;} s;
module top; parameter int N = $bits(s); localparam L = $bits(s); endmodule
