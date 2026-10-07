// § leftoverTsCopyPerElabUse272
// a packed union parameter built by a function (the law stands aside)
package pk;
  typedef struct packed { logic [15:0] a; logic [15:0] b; } in_t;
  typedef union packed { in_t s; logic [31:0] w; } u_t;
  localparam in_t UU = '{a: 16'd11, b: 16'd22};
  function automatic u_t mk();
    u_t c; c.s = UU; return c;
  endfunction
  localparam u_t C = mk();
endpackage
module kid #(parameter pk::u_t P = pk::C) (output logic o);
  localparam int unsigned RD = P.s.a;
  assign o = '0;
endmodule
module dut(output logic o); kid k0 (.o(o)); endmodule
