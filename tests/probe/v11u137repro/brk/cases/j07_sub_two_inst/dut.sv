// § defNetScopedPkgArrTdShares137
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b[5:0];
endpackage
module sub(output o);
  pkg::b c;
  assign c[1].x = 1;
  assign o = c[1].x;
endmodule
module dut(output o1, o2);
  sub u1(.o(o1));
  sub u2(.o(o2));
endmodule
