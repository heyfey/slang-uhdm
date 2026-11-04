// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [7:0] v, input logic [2:0] i [2]);
  for (genvar g = 0; g < 2; g++) begin : G
    mod m(.a(v[i[g]]));
  end
endmodule
