module top #(parameter int N = 4)(input logic [31:0] a, output logic [31:0] o [0:1]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign o[g] = (g < 1) ? 32'd9 : '0;
  end
endmodule
