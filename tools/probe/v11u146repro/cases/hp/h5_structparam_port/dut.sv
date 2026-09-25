// § constPathBaseAnyKind146
typedef struct packed { int A; int B; } cfg_t;
module child #(parameter cfg_t C = '{A: 4, B: 2}) (input logic [C.A-1:0] d, output logic [C.A-1:0] q);
  assign q = d;
endmodule
module top(input logic [3:0] d, output logic [3:0] q);
  child c(.d(d), .q(q));
endmodule
