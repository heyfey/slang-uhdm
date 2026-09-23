package pk;
  parameter logic [6:0] P_LIT = 7'h73;
  parameter int P_INT = 5;
endpackage
module dut import pk::*; (input logic [6:0] x, output logic [3:0] y [2][2]);
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      always_comb begin
        case (x)
          P_LIT: y[f][b] = 1;
          P_INT: y[f][b] = 2;
          default: y[f][b] = 0;
        endcase
      end
    end
  end
endmodule
