// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
module top; if (1) begin : g localparam int N = $bits(s); localparam int M = N + 1; logic [7:0] y; assign y = M; end endmodule
