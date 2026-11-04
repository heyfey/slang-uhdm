// § unitTdLawS245
// $unit scalar typedefs used as members of a $unit packed struct and an unpacked struct
typedef int ui_t;
typedef logic [7:0] ub_t;
typedef struct packed { ub_t a; ui_t b; } s_t;
typedef struct { ub_t c; ui_t d; } u_t;
module top;
  s_t s;
  u_t u;
  ub_t v;
  assign v = s.a;
endmodule
