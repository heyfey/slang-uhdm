// § leftoverTsCopyPerElabUse272
// two packages each with a function-built struct parameter
package pa;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 1, b: 2};
  function automatic c_t mk(); c_t c; c.u = UU; c.d = 3; return c; endfunction
  localparam c_t C = mk();
endpackage
package pb;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
  localparam in_t UU = '{a: 8'd4, b: 8'd5};
  function automatic c_t mk(); c_t c; c.u = UU; c.d = 8'd6; return c; endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pa::c_t P = pa::C, parameter pb::c_t R = pb::C) (output logic o);
  localparam int unsigned RD = P.d + R.d;
  assign o = '0;
endmodule
module dut(output logic o); kid k0 (.o(o)); endmodule
