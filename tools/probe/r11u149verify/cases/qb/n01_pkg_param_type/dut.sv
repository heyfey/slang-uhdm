// § pkgTsForeignQualRefUnstored144
package p;
  parameter int W = 4;
endpackage
package q;
  parameter logic [p::W-1:0] Z = 3;
endpackage
module dut(output logic [3:0] o);
  assign o = q::Z;
endmodule
