// § leftoverTsCopyPerElabUse272
// the parameter in an if-generate condition and a case-generate
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic [1:0] o);
  if (P.d == 64) begin : ga
    assign o[0] = 1'b1;
  end else begin : gb
    assign o[0] = 1'b0;
  end
  case (P.u.a)
    11: begin : gc assign o[1] = 1'b1; end
    default: begin : gd assign o[1] = 1'b0; end
  endcase
endmodule
module dut(output logic [1:0] o);
  kid k0 (.o(o));
endmodule
