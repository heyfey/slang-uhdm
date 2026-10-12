// § modFnLitLeftoverValueGate302v
// vl18: the builder's argument default omitted, the default arm being the first one written
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk(input bit s = 1'b1);
    pk::c_t c; c.a = 2; if (s) c.b = 21; else c.b = 22; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam logic [7:0] LB = L.b;
  assign o = 1'b0;
endmodule
