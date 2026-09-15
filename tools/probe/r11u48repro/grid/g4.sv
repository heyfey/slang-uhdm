// g4 — a MODULE function body calling another with a body local.
module g4 (output logic [f(3)-1:0] o);
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned f(int unsigned n);
    automatic int unsigned k = n;
    return w(k);
  endfunction
  assign o = '0;
endmodule
