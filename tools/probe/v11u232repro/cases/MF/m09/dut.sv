// § caCallArgParamFormalTs232
package q;
  typedef logic [0:2] mask_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pr_t;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  function automatic int unsigned cnt(mask_t cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
  function automatic int unsigned w8(logic [7:0] x);
    return x + 1;
  endfunction
  function automatic int unsigned w4(logic [3:0] x);
    return x + 2;
  endfunction
  function automatic int unsigned ef(e_t x);
    return x;
  endfunction
  function automatic int unsigned sf(string s);
    return s.len();
  endfunction
  function automatic int unsigned pf(pr_t x);
    return x.a + x.b;
  endfunction
endpackage
// an interface body and an implicit net beside the call
interface ifc #(parameter logic [7:0] N = 3);
  int o;
  assign o = q::w8(N);
endinterface
module top(output int o, output int z);
  ifc #(.N(8'd7)) i ();
  assign o = i.o;
  assign imp = q::w4(4'd3);
  assign z = imp;
endmodule
