// § hcSelIdxInstName168 § macroConnInRange166
`define CN(p, s, i) .p(s[i])
module mod(input logic a);
endmodule
module dut(input logic [7:0] v, input logic [2:0] i [2]);
  for (genvar g = 0; g < 2; g++) begin : G
    mod m(`CN(a, v, i[g]));
  end
  mod n(`CN(a, v,
            i[1]));
endmodule
