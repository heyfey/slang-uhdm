// § caCallArgParamFormalTs232
package q;
  typedef logic [0:2] mask_t;
  function automatic int unsigned cnt(mask_t cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
endpackage
module sub #(parameter q::mask_t M = '0) (input logic [q::cnt(M)-1:0] a, output logic [q::cnt(M)-1:0] b);
  assign b = ~a;
endmodule
module top(input logic [1:0] a, output logic [1:0] b);
  sub #(.M(3'b101)) u (.a(a), .b(b));
endmodule
