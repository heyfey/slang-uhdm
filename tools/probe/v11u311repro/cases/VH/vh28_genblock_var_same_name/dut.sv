// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y, z);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i;
  sub u (.a(q.f[i]), .y(y));
  if (1) begin : g
    int i;
    sub v (.a(q.f[i]), .y(z));
  end
endmodule
