// § oneTickUpperBNormalized425
module top(input logic a, output logic y, output logic z);
  function automatic logic f(input logic x);
    if (x == 1'B1) return 1'B0;
    return 1'B1;
  endfunction
  assign y = f(1'B0);
  assign z = f(a);
endmodule
