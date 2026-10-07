// § leftoverTsCopyPerElabUse272
// a top-level localparam (r11vu13 v3 shape, no other face) defaulting to the package name of a wider struct (a converted value)
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module dut(output logic o);
  localparam pk::in_t Cut = pk::C;
  localparam int unsigned RD = Cut.a;
  assign o = '0;
endmodule
