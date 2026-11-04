// § lotsCopyNestedGenWalk274
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic [31:0] o);
  localparam int unsigned RD1 = P.u.a[0];
  assign o = '0;
endmodule
module mid (output logic [31:0] o [2]);
  for (genvar i = 0; i < 1; i++) begin : a
    for (genvar j = 0; j < 2; j++) begin : b
      kid kk (.o(o[j]));
    end
  end
endmodule
module dut(output logic [31:0] o [2]); mid m (.o(o)); endmodule
