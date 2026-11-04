// G2: BlackParrotComplex's `bottom`: an untyped parameter reads an element
// and a generate-if tests it.
module bottom ();
  parameter int A3[0:2] = {1, 2, 3};
  parameter A = A3[2];
  if (A != 3) begin : g
    initial $display("bad");
  end
endmodule
module top ();
  bottom b();
endmodule
