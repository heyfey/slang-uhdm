// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [31:0] v, input logic [4:0] i);
   for (genvar g = 0; g < 2; g++) begin : G
     mod m(.a(v[i]));
   end
endmodule
