// § unitLawSSkipAliasedListing245v
// a $unit packed array of a $unit typedef as a packed struct member, two instances
typedef logic [1:0] e_t;
typedef e_t [1:0] arr_t;
typedef struct packed { arr_t a; logic b; } s_t;
module sub(input logic [4:0] i, output logic [3:0] o);
  s_t s;
  assign s = i;
  assign o = s.a;
endmodule
module top(input logic [4:0] i, output logic [3:0] o1, o2);
  sub u1(.i(i), .o(o1));
  sub u2(.i(~i), .o(o2));
endmodule
