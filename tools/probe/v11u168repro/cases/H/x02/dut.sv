// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [7:0] v);
   for (genvar g = 0; g < 2; g++) begin : G
      mod m(.a(v[g]));
   end
endmodule
