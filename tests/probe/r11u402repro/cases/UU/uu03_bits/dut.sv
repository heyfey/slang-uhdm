// § modUnpackedUnionTd402
module top(input logic [7:0] i, output logic [7:0] o);
  typedef union { logic [7:0] a; logic [7:0] b; } u_t;
  u_t x;
  assign x.a = i;
  assign o = x.b;
endmodule
