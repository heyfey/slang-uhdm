// § pkgTsForeignQualRefUnstored144
package p;
  parameter int W = 4;
endpackage
package q;
  logic [p::W-1:0] v;
endpackage
module dut(output logic [3:0] o);
  assign o = q::v;
endmodule
