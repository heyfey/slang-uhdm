// § genProcOpFoldInPlace282
package pk; parameter int NB = 3; parameter int ND = 2; endpackage
module top import pk::*; (output logic [7:0] r [2]);
  function automatic logic [7:0] f(input logic [7:0] x); return x; endfunction
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb r[w] = f(NB + ND) + $clog2(NB + 1);
  end
endmodule
