// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module mid #(parameter int W = 2) (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; int k;
  sub u (.a(q.f[k + W]), .y(y));
endmodule
module dut(output logic y, output logic z);
  mid #(.W(3)) m1 (.y(y));
  mid m2 (.y(z));
endmodule
