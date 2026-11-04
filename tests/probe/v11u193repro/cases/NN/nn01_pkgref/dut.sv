// § nestChainKeepsPkgQual193v
package pk;
  parameter int W = 4;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module sub ();
  module inner import pk::*; (output logic [3:0] q);
    e_t st;
    assign st = B;
    assign q = pk::W + 4'(st);
  endmodule
  wire [3:0] w = 4'd1;
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
