// § paramFoldParenSpan131
package pk;
  localparam int A = (3 + 5);
endpackage
module top (output logic [31:0] o);
  localparam int L = pk::A;
  assign o = L;
endmodule
