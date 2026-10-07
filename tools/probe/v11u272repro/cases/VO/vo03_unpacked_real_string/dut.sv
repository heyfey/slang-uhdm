// § leftoverTsCopyPerElabUse272
// an unpacked struct with real and string members
package pk;
  typedef struct { real r; string s; int unsigned n; } c_t;
  function automatic c_t mk();
    c_t c; c.r = 1.5; c.s = "ab"; c.n = 3; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic o);
  localparam int unsigned RD = P.n;
  assign o = '0;
endmodule
module dut(output logic o); kid k0 (.o(o)); endmodule
