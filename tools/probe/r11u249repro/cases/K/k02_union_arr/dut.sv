// § unitUnpackedUnionTd249
typedef union { bit [3:0] a [2]; int unsigned w; } un_t;
module top(input logic [3:0] a, output logic [3:0] o);
  un_t u;
  assign u.a[0] = a;
  assign o = u.a[0];
endmodule
