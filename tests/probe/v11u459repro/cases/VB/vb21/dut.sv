// § pkgBitsTypeEnumZero459
typedef enum {A,B} e; typedef struct packed {logic [3:0] a; e b;} s;
module m #(parameter type T = s)(output logic [7:0] y); localparam int W = $bits(T); assign y = W; endmodule
module top(output logic [7:0] y0, y1); m u(y0); m #(.T(logic [5:0])) v(y1); endmodule
