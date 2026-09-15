// va7 — a STATIC body local (lifetime static) in a package function's return
// expression, plus an automatic twin.
package va7p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned f(int unsigned n);
    static int unsigned sk = 1;
    automatic int unsigned ak = 2;
    return w(sk) + w(ak);
  endfunction
endpackage
module va7 (input logic c, output logic o);
  assign o = c;
endmodule
