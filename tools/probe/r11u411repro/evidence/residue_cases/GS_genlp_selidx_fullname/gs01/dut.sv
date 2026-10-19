// residue (not written): generate-localparam select index full name and fold
module top #(parameter logic [7:0] M = 8'h5A) (output logic [3:0] o);
  genvar i;
  for (i = 0; i < 4; i = i + 1) begin : rof
    localparam lo = M[i];
    localparam hi = M[i+1];
    assign o[i] = lo ^ hi;
  end
endmodule
