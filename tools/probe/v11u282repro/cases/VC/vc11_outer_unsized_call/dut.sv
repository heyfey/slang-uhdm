// § genCaSelBoundUnsizedClone282
module top #(parameter int P = 2) (input logic [7:0] b, output logic [1:0] z [2]);
  function automatic logic [1:0] f(input logic [1:0] x); return x; endfunction
  for (genvar g = 0; g < 2; g++) begin : gb
    assign z[g] = f('1) | b[P +: 2];
  end
endmodule
