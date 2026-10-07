// § leftoverTsCopyPerElabUse272
// the parameter read in RTL: members, slots, a function and always_comb
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (input logic [7:0] i, output logic [7:0] o, output logic [31:0] q);
  logic [P.u.a-1:0] w;
  function automatic logic [7:0] f(input logic [7:0] x); return x + P.u.b[7:0]; endfunction
  always_comb begin
    w = '0;
    o = f(i) ^ {P.d[2:0], 5'b0};
  end
  assign q = P.d + P.u.a;
endmodule
module dut(input logic [7:0] i, output logic [7:0] o, output logic [31:0] q);
  kid k0 (.i(i), .o(o), .q(q));
endmodule
