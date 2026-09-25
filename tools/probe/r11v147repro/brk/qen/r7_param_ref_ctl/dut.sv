// § enumQualDefaultDefSpan147
package pk;
  localparam int K = 3;
endpackage
module top(output logic [1:0] o);
  parameter int P = pk::K;
  assign o = P[1:0];
endmodule
