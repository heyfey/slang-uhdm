// § castTsInPathIdxByChain296
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [3:0] k;
  function automatic logic fn(input logic [3:0] kk);
    return q.f[3'(kk)];
  endfunction
  assign o = fn(k);
endmodule
