// § pkgVarLvalueScopeSep292
package q;
  int qi = 3;
endpackage
module top;
  int y;
  always_comb begin
    q::qi = 5;
    y = q::qi;
  end
endmodule
