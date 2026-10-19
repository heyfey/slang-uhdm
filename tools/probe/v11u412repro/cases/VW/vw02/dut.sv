// § assocWildcardIdxRefTs412
class C;
  int carr [*];
endclass
package pk;
  int parr [*];
endpackage
module top;
  C c;
  for (genvar g = 0; g < 1; g++) begin : gb
    int garr [*];
  end
endmodule
