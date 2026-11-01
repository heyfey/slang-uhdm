// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
module top; localparam int N = $bits(s) / 2; genvar i; for (i = 0; i < N; i++) begin : g logic q; end endmodule
