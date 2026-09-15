// g5 — a MODULE function body calling another with its OWN FORMAL.
module g5 (output logic [f(3)-1:0] o);
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned f(int unsigned n); return w(n); endfunction
  assign o = '0;
endmodule
