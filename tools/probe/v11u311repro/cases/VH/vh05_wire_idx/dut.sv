// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (input logic [4:0] w, output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  wire [4:0] k = w;
  sub u (.a(q.f[k]), .y(y));
endmodule
