// § modPatLeftoverCloneNoParent302
// vp04: the pattern localparam typed by a $unit typedef
typedef struct packed { int unsigned a; int unsigned b; } in_t;
typedef struct packed { in_t u; int unsigned d; } c_t;
module dut(output logic o);
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t L = mk();
  localparam in_t MS = L.u;
  assign o = 1'b0;
endmodule
