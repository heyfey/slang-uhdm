// g11 — a body local passed to a call in a MODULE function whose body IS
// constant-evaluated from a range.
module g11 (output logic [f(3)-1:0] o);
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned f(int unsigned n);
    automatic int unsigned k = n;
    automatic int unsigned r = w(k);
    return r;
  endfunction
  assign o = '0;
endmodule
