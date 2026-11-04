// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [7:0] v, input logic [2:0] i);
   for (genvar g = 0; g < 2; g++) begin : G
      logic [2:0] s;
      assign s = i + g;
      mod m(.a(v[s]));
   end
endmodule
