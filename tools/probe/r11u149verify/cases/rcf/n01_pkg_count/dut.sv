// § replCountFoldFile140
package p;
  parameter int N = 3;
endpackage
module dut(input logic [1:0] s, output logic [7:0] o);
  localparam logic [7:0] A [p::N] = '{p::N{8'h11}};
  assign o = A[s];
endmodule
