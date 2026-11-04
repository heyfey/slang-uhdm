// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [7:0] a; e b;} s;
module m #(parameter int N = $bits(s), parameter int K = N*2)(); localparam int L = N + 1; endmodule
module top; m u(); m #(.N(5)) v(); endmodule
