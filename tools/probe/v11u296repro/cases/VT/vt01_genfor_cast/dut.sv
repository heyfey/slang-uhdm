// § castTsInPathIdxByChain296
module dut(output logic [1:0] o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [3:0] k;
  for (genvar g = 0; g < 2; g++) begin : gb
    assign o[g] = q.f[2'(k) + g];
  end
endmodule
