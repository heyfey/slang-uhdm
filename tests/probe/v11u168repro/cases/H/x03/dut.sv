// § hcSelIdxInstName168
package pkg;
  parameter int I = 2;
endpackage
module mod(input logic a);
endmodule
module dut(input logic [7:0] v);
   mod m(.a(v[pkg::I]));
endmodule
