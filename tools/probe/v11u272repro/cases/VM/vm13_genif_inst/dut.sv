// § leftoverTsCopyPerElabUse272
// (no continuous-assignment read of the parameter) a child inside an if-generate and a case-generate
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic o);
  localparam int unsigned RD1 = P.d[0];
  assign o = '0;
endmodule
module dut #(parameter int N = 1) (output logic [1:0] o);
  if (N == 1) begin : gi
    kid k (.o(o[0]));
  end
  case (N)
    1: begin : gc kid k (.o(o[1])); end
    default: begin : gd assign o[1] = 1'b0; end
  endcase
endmodule
