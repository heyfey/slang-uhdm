// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
module top(input logic [7:0] x, output logic y); always_comb begin if (x == $bits(s) + 0) y = 1; else y = 0; end endmodule
