// § defNetScopedPkgArrTdShares137
package pkg;
   typedef struct packed {
      logic x;
   } a;
   typedef a b[1:0];
endpackage
module sub(output o);
   pkg::b c;
   assign c[0].x = 1;
   assign o = c[0].x;
endmodule
module dut(output o);
   sub u(.o(o));
endmodule
