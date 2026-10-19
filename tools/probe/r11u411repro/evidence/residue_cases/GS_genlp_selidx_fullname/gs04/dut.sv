// residue (not written): generate-localparam select index full name and fold
module top #(parameter logic [7:0] M = 8'h5A) (output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : rof
    localparam lo = M[i] + M[2*i];
    assign o[i] = lo;
  end
endmodule
