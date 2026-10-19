// residue (not written): generate-localparam select index full name and fold
module top #(parameter int M [4] = '{1, 2, 3, 4}) (output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : rof
    localparam lo = M[i];
    assign o[i] = lo[0];
  end
endmodule
