// § caPlainLhsUnsizedClone438 (control: a Rhs reading a parameter only abstains)
module sub #(parameter [15:0] P = 16'h1234) (output y);
  assign y = P['hA];
endmodule
module top(output y);
  sub u(.y(y));
endmodule
