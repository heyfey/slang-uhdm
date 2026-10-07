// § leftoverTsCopyPerElabUse272
// the parameter passed to a package function in a continuous assign and as a call index
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
  function automatic int unsigned getd(c_t x); return x.d; endfunction
  function automatic int unsigned idx(int unsigned v); return v % 4; endfunction
endpackage
module kid #(parameter pk::c_t P = pk::C) (input logic [3:0] i, output logic [31:0] o, output logic b);
  assign o = pk::getd(P);
  assign b = i[pk::idx(P.u.a)];
endmodule
module dut(input logic [3:0] i, output logic [31:0] o, output logic b);
  kid k0 (.i(i), .o(o), .b(b));
endmodule
