// § elabParamRefSignedTsUnlocated264
package fp;
  localparam int K = 3;
endpackage
module er import fp::*; (output logic [7:0] q);
  localparam int M = 3;
  localparam int K = M;
  localparam int J = M;
  assign q = K + J;
endmodule
module top(output logic [7:0] q);
  er u (.q(q));
endmodule
