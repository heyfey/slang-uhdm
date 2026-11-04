// § unitUnpackedUnionTd249
typedef union { int a; logic [3:0] b; } u_t;
typedef struct { u_t u; int k; } s_t;
module top; s_t s; endmodule
