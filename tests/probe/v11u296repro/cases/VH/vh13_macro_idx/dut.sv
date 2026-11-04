// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module sub4 (input logic [3:0] a, output logic y);
  assign y = a[0];
endmodule
module dut(output logic y, output logic y2, output logic y3);
  typedef struct packed {logic [31:0] f; logic [7:0] g;} st_t;
  `define IX(x) x
  st_t q; int i;
  sub u (.a(q.f[`IX(i)]), .y(y));
  assign y2 = 0; assign y3 = 0;
endmodule
