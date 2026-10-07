// § scopedClassRetQualSpan283
package fp;
  class LL; int y = 1; endclass
  class PP #(int W = 4); int y; endclass
  typedef LL ll_t;
endpackage
module m1 (output logic [31:0] o);
`include "fn.svh"
  assign o = 32'd0;
endmodule
module m2 (output logic [31:0] o);
`include "fn.svh"
  assign o = 32'd1;
endmodule
module dut (output logic [31:0] o, p);
  m1 a (.o(o)); m2 b (.o(p));
endmodule
