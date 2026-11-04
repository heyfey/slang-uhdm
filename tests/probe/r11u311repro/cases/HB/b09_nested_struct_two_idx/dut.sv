// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [3:0][7:0] g;} in_t;
  typedef struct packed {in_t h;} out_t;
  out_t z;
  int i, j;
  sub u (.a(z.h.g[i][j]), .y(y));
endmodule
