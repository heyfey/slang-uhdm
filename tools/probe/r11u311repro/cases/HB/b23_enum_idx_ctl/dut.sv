// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef enum logic [4:0] {E0 = 5'd3, E1} e_t;
  st_t q;
  sub u (.a(q.f[E1]), .y(y));
endmodule
