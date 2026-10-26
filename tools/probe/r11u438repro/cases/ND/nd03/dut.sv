// § ndaUnsizedRhsFreshLhs438 (control: a parameter-only initializer folds)
module sub #(parameter [15:0] P = 16'h1234) (output y);
  wire w = P['hA];
  assign y = w;
endmodule
module top(output y);
  sub u(.y(y));
endmodule
