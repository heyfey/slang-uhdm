// § bitSelMethodCallIdxSpan207 (a method call index inside an always block and a continuous assignment of a module; a multi-line argument list)
class H;
  function int get(int i); return i % 4; endfunction
endclass
module m03 (input logic [3:0] a, input int k, output logic y, output logic z);
  H h = new;
  always_comb y = a[h.get(
                      k)];
  initial z = a[h.get(k + 1)];
endmodule
