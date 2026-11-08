// § enumCastChainKeepsInnerCast493
class PC #(int W = 8);
  static function logic [W-1:0] f(logic [W-1:0] s);
    return W'(W'(s));
  endfunction
endclass
module top(input logic [7:0] a, output logic [7:0] v);
  assign v = PC#(8)::f(a);
endmodule
