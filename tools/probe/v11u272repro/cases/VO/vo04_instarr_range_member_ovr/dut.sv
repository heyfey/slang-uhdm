// § leftoverTsCopyPerElabUse272
// the parameter in an instance-array range and a member-select override of a grandchild
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module gk #(parameter pk::in_t Q = pk::UU) (output logic o);
  localparam int unsigned RD = Q.b;
  assign o = '0;
endmodule
module kid #(parameter pk::c_t P = pk::C) (output logic [1:0] o);
  gk #(.Q(P.u)) g[P.u.a-10:0] (.o(o));
endmodule
module dut(output logic [1:0] o); kid k0 (.o(o)); endmodule
