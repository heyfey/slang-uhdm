// § paramIdxPartSelWholeSpan131
package pk;
  localparam logic [31:0] A = 32'hcafef00d;
  localparam logic [7:0] B = A[15 -: 8];
endpackage
module top (output logic [7:0] o);
  assign o = pk::B;
endmodule
