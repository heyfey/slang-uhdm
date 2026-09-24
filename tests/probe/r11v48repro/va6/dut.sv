// va6 — a MODULE-level variable as a call argument (golden STAMPS; must stay).
module va6 (input logic c, output logic o);
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  int unsigned v;
  int unsigned r;
  always_comb r = w(v);
  assign o = c ^ r[0];
endmodule
