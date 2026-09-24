// § aliasCloneTakesTargetFile137
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b[5:0];
  typedef a c[3:0];
endpackage
module dut(output o);
  pkg::b u;
  pkg::c v;
  assign u[0].x = 1;
  assign v[0].x = 1;
  assign o = u[0].x ^ v[1].x;
endmodule
