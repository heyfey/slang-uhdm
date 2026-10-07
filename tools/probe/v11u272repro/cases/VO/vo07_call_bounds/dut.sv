// § leftoverTsCopyPerElabUse272
// a call in a part-select bound and as an index, an inc/dec on a local indexed by the parameter
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (input logic [31:0] i, output logic [7:0] o);
  function automatic int f(int x); return x % 8; endfunction
  logic [7:0] cnt [4];
  always_comb begin
    o = i[f(P.u.a)+:8];
    cnt[P.u.a % 4] = '0;
    cnt[f(P.d) % 4]++;
  end
endmodule
module dut(input logic [31:0] i, output logic [7:0] o); kid k0 (.i(i), .o(o)); endmodule
