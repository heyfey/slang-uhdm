module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  for (genvar g = 0; g < 2; g++) begin : gf
    logic [31:0] fv;
    assign fv = a & 32'hff;
  end
  assign o2 = gf[0].fv;
endmodule
