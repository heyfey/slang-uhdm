// § bodyParamNoHdrList262v (a header localparam only, the body localparam read)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(localparam bit E = 1) (input logic [7:0] a, output logic [1:0] r);
  localparam int K = 2;
  assign r = a[K +: 2] & {2{E}};
endmodule
module top(input logic [7:0] a, output logic [1:0] r);
  ctrl u (.a(a), .r(r));
endmodule
