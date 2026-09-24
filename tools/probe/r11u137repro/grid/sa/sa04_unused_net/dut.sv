// § defNetScopedPkgArrTdShares137
package pkg;
   typedef struct packed {
      logic x;
   } a;
   typedef a b[5:0];
endpackage
module dut();
   pkg::b c;
endmodule
