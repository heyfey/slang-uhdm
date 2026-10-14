// § ipsBaseOpSysRender314
`define BB IDW-1
typedef struct packed { logic [7:0] a; } s_t;
module top; localparam int IDW = 8; s_t q [2]; for (genvar i = 0; i < 2; i++) begin : g assign q[i].a[`BB-:2] = 2'b0; end endmodule
