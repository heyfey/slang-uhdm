// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
module top(input logic [7:0] x, output logic [7:0] y); localparam int W = $bits(s); localparam int H = W / 2;
  assign y = x + H; endmodule
