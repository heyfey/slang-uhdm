// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  e_t e;
  sub u (.a(q.f[e]), .y(y));
endmodule
