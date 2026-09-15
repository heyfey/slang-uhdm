// va2 — a package function body local passed as an argument in a PLAIN
// ASSIGNMENT statement (no loop, no if, no return), never evaluated.
package va2p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned f(int unsigned n);
    int unsigned k = n;
    int unsigned r;
    r = w(k);
    return r;
  endfunction
endpackage
module va2 (input logic c, output logic o);
  assign o = c;
endmodule
