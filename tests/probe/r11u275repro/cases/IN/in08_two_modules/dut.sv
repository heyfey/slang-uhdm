// § importNetTsDimEnd275 — two importers of one package
package p;
  logic [3:0][1:0] k;
  logic [7:0] a [0:3];
endpackage
module sub (output logic [7:0] o);
  import p::*;
  assign o = k;
endmodule
module dut (output logic [7:0] o, output logic [7:0] q);
  import p::*;
  sub u (.o(o));
  assign q = a[2];
endmodule
