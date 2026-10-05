// § unitTdLawS245
// a $unit vector typedef as a packed struct member, the struct a $unit typedef too
typedef logic [3:0] nib_t;
typedef struct packed { nib_t a; logic b; } s_t;
module top(input logic [4:0] i, output logic [3:0] o);
  s_t s;
  assign s = i;
  assign o = s.a;
endmodule
