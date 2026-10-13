// § ipsBaseSelCallRender312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; logic [1:0] w [4]; wire [1:0] o; assign o = a.v[w[0] +: 2]; endmodule
