// § unitUnpackedUnionTd249
typedef union { int a; int unsigned w; } un_t;
module top(input logic [31:0] a, output logic [31:0] o);
  un_t u;
  assign u.a = a;
  assign o = u.w;
endmodule
