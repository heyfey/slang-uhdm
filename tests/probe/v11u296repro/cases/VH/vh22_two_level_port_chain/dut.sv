// § hcTrailIdxNamesByPortChain296
module leaf (input logic a, output logic y);
  assign y = a;
endmodule
module mid (input logic [31:0] v, input int i, output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  assign q.f = v;
  leaf l (.a(q.f[i]), .y(y));
endmodule
module dut(input logic [31:0] v, input int i, output logic y, output logic z);
  mid m1 (.v(v), .i(i), .y(y));
  mid m2 (.v(~v), .i(i), .y(z));
endmodule
