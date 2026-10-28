// § unpackedDimBasedLitKept454
package p;
  int pa[8'h2:'h5];
endpackage
interface ifc;
  logic iv['d1:4'b0011];
endinterface
class C;
  bit b[8'sd1:'o7];
endclass
module top;
  ifc u();
  C c;
  logic [7:0] m2[32'h10:32'h1F];
  int mz['h0:'h3];
endmodule
