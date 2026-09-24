// § defNetScopedPkgArrTdShares137
package pkg;
   typedef logic [3:0] b [1:0];
endpackage
module dut(output logic [3:0] o);
   pkg::b c;
   assign c[1] = 4'h3;
   assign o = c[1];
endmodule
