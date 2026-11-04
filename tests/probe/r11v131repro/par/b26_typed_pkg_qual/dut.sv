// § paramFoldParenSpan131
package pk;
  localparam int A = (3 + 5);
endpackage
module top ();
  localparam int L = pk::A;
endmodule
