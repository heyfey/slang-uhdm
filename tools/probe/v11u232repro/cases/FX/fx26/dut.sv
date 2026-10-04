// § caCallArgCastAbstains232v
package q;
  typedef logic [0:2] mask_t;
  function automatic int unsigned cnt(mask_t cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
  function automatic int unsigned w(int unsigned x);
    return x + 1;
  endfunction
  function automatic int unsigned w2(logic [7:0] x, int unsigned y);
    return x + y;
  endfunction
endpackage
// a class specialization in a bound beside the call; a cast in one call, a plain argument in another
class C #(int W = 2);
  localparam int V = W + 1;
endclass
module sub #(parameter q::mask_t M = '0) (output int o, output logic [C#(4)::V-1:0] r);
  assign o = q::cnt(M);
  assign r = q::cnt(q::mask_t'(M));
endmodule
module top(output int o, output logic [4:0] r);
  sub #(.M(3'b101)) u (.o(o), .r(r));
endmodule
