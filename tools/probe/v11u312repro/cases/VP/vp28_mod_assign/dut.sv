// § ipsBaseSelCallRender312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; localparam int ix[4] = '{0, 1, 2, 3}; assign a.v[ix[1] +: 2] = 2'b0; endmodule
