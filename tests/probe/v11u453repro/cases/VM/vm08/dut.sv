// § modCopyImportsFirst453
package a;
  int va;
endpackage
package b;
  int vb;
  import a::*;
endpackage
module sub;
  import b::*;
  logic z;
endmodule
module top;
  sub u();
  for (genvar g = 0; g < 2; g++) begin : gb
    sub v();
  end
endmodule
