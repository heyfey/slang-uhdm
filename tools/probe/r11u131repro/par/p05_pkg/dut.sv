// § paramFoldParenSpan131
package pk;
  parameter int X = (2+3);
  localparam int Y = (X*2);
endpackage
module top ();
  logic [pk::Y:0] a;
endmodule
