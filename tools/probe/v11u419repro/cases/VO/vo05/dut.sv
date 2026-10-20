// § implicitPortParamListedFirst419
program pr #(parameter A = 1, int B = 2) ();
  initial $display(A, B);
endprogram
module top;
  pr u();
endmodule
