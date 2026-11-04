// § gcaChainInsideSetKeepsInst169v
module dut (input logic [31:0] a [2], output logic [31:0] o [2]);
  parameter int P = 6;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = {a[c][0] inside {P}, 31'b0};
  end
endmodule
