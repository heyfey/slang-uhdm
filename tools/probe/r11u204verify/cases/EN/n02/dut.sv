// § classPropElemClassTsAtName196: value-parameter element specializations (positional, named) in queue, dynamic and fixed dimensions, rand and static qualifiers
package p;
  class vec #(int W = 8); logic [W-1:0] d; endclass
  class holder;
    rand vec#(4) q[$];
    vec#(.W(16)) dyn[];
    static vec#(2) fx[3];
    local vec #( 12 ) sp[2];
  endclass
endpackage
module top; endmodule
