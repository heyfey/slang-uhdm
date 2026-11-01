// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
module m #(parameter int N = 1)(); localparam int M = N + 1; endmodule
module top; m #(.N($bits(s) + 1)) u(); endmodule
