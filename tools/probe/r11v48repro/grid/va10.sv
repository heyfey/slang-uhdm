// va10 — a function local inside an INTERFACE, return expression.
interface va10i (input logic c);
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned f(int unsigned n);
    int unsigned k = n;
    return w(k);
  endfunction
endinterface
module va10 (input logic c, output logic o);
  assign o = c;
endmodule
