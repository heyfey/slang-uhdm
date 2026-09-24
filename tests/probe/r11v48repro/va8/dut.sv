// va8 — a local declared in a NAMED BLOCK inside a package function, used in a
// call inside the same block and again in the return expression.
package va8p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned f(int unsigned n);
    int unsigned acc = 0;
    begin : nb
      int unsigned k = n;
      acc = w(k);
    end
    return w(acc);
  endfunction
endpackage
module va8 (input logic c, output logic o);
  assign o = c;
endmodule
