package r40;
  parameter logic [3:0][7:0] A = {8'h1, 8'h2, 8'h3, 8'h4};
endpackage
module v40_orphan #(parameter int DW = 8) (output logic [3:0] o);
  for (genvar g = 0; g < 1; g++) begin : gb
    logic [3:0] c_ips;
    assign c_ips = r40::A[g][DW-1 -: 4];
  end
  assign o = gb[0].c_ips;
endmodule
