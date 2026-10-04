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
// instances depth 3, in an if-generate and a for-generate; the call in a replication count and a localparam
module leaf #(parameter logic [7:0] N = 1) (output logic [15:0] o);
  localparam int L = q::w4(N);
  assign o = {q::w4(N){1'b1}};
endmodule
module mid #(parameter logic [7:0] N = 2) (output logic [15:0] o);
  leaf #(.N(N)) l (.o(o));
endmodule
module top #(parameter bit G = 1) (output logic [15:0] o, output logic [15:0] p [2]);
  if (G) begin : g
    mid #(.N(8'd3)) m (.o(o));
  end
  for (genvar i = 0; i < 2; i++) begin : f
    leaf #(.N(8'd4 + i)) l (.o(p[i]));
  end
endmodule
