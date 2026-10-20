// residue (no law landed): a parenthesized gate-terminal index bit_select span (ModuleEmit, sister ground), see README
module top(input [7:0] a, input [2:0] k, output z, output w);
  assign z = a[(k+1)];
  assign w = a[(k)] & a[((k - 1))];
endmodule
