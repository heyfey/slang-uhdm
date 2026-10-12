// § paramInitMemberSelFoldBaseSpan294
// the reading parameter overridden at the instance (the law stands aside)
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; logic [7:0] v; } c_t;
  function automatic c_t mk();
    c_t c; c.u.a = 3; c.u.b = 32; c.d = 64; c.v = 8'h5A; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t CFG = pk::C, parameter int B = CFG.d[6]) (output logic o);
  assign o = ^{B, 1'b0};
endmodule
module dut(output logic o); kid #(.B(1)) k0 (.o(o)); endmodule
