// § unitUnpackedUnionTd249
typedef union { int a; int b; } u_t;
class c; u_t m; endclass
module top; c h; u_t v; endmodule
