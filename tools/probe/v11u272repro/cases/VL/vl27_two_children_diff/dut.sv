// § leftoverTsCopyPerElabUse272
// two child modules with the same default and a module with an override by a module-local function
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module ka #(parameter pk::c_t P = pk::C) (output logic [31:0] o); assign o = P.d; endmodule
module kb #(parameter pk::c_t P = pk::C) (output logic [31:0] o); assign o = P.u.b; endmodule
module dut(output logic [31:0] o, output logic [31:0] p);
  ka a0 (.o(o));
  kb b0 (.o(p));
endmodule
