// § unitTdLawS245
// a $unit longint typedef as a packed struct member
typedef longint li_t;
typedef struct packed { li_t a; logic [3:0] b; } s_t;
module top(input logic [67:0] i, output logic [3:0] o);
  s_t s;
  assign s = i;
  assign o = s.b;
endmodule
