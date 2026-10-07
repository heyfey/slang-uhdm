// § leftoverTsCopyPerElabUse272
// a loop in the builder function
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
  function automatic c_t mk();
    c_t c; c.a = 0; c.b = 1;
    for (int i = 0; i < 3; i++) c.a += i;
    return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic [31:0] o);
  assign o = P.a;
endmodule
module dut(output logic [31:0] o);
  kid k0 (.o(o));
endmodule
