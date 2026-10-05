// § impArrParamTsOwnRanges242
// The importer at depth 3 (inside an if-generate and a for-generate), two parameterisations, the array read through a function of the importer and in an always_comb loop.
package hp;
  parameter logic [15:0] K [4] = '{16'h11, 16'h22, 16'h33, 16'h44};
endpackage
module leaf import hp::*; #(parameter int I = 0) (input logic [1:0] i, output logic [15:0] o);
  function automatic logic [15:0] pick(logic [1:0] j); return K[j] ^ K[I]; endfunction
  always_comb begin
    o = '0;
    for (int k = 0; k < 4; k++) o = o ^ K[k];
    o = o ^ pick(i);
  end
endmodule
module mid #(parameter int J = 0) (input logic [1:0] i, output logic [15:0] o);
  if (J == 0) begin : gi
    leaf #(.I(J)) u (.i(i), .o(o));
  end else begin : ge
    leaf #(.I(J+1)) u (.i(i), .o(o));
  end
endmodule
module top (input logic [1:0] i, output logic [15:0] o [2]);
  for (genvar g = 0; g < 2; g++) begin : gl
    mid #(.J(g)) m (.i(i), .o(o[g]));
  end
endmodule
