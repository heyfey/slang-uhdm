// § lotsCopyNestedGenWalk274
// a child three generate levels down (for / if / for) of a struct parameter with a leftover
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
  assign o = '0;
endmodule
module dut(output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g1
    if (i >= 0) begin : g2
      for (genvar j = 0; j < 2; j++) begin : g3
        kid k (.o(o[i*2+j]));
      end
    end
  end
endmodule
