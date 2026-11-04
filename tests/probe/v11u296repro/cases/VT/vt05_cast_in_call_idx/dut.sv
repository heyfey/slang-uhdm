// § castTsInPathIdxByChain296
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [7:0] k;
  function automatic int g(input int x); return x; endfunction
  assign o = q.f[g(int'(k))];
endmodule
