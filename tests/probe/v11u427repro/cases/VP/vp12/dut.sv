// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b1x01;
endpackage
module top(output logic [3:0] o);
  always_comb begin
    o = p::B;
    if (o == p::B) o = 0;
  end
endmodule
