// § modFnLitLeftoverAtLiteral302
// l04: the module localparam is passed down as an override
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module kid #(parameter pk::c_t CFG = '{a: 0, b: 0}) (output logic o);
  localparam int unsigned S = CFG.b;
  assign o = 1'b0;
endmodule
module dut(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 11; c.b = 22; return c;
  endfunction
  localparam pk::c_t L = mk();
  kid #(.CFG(L)) k0 (.o(o));
endmodule
