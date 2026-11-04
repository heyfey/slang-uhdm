// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module top (input logic [31:0] d, input logic [4:0] i, output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  assign q.f = d;
  sub u (.a(q.f[i]), .y(y));
endmodule
