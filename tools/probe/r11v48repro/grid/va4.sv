// va4 — a package TASK body local passed as a call argument.
package va4p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  task automatic t(int unsigned n);
    int unsigned k = n;
    int unsigned r;
    r = w(k);
  endtask
endpackage
module va4 (input logic c, output logic o);
  assign o = c;
endmodule
