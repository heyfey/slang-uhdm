// § unitUnpackedUnionTd249
typedef union { int a; real r; } u_t;
typedef union { logic [1:0] x; logic [1:0] y; } w_t;
class c; u_t m; w_t n; endclass
module top; c h; endmodule
