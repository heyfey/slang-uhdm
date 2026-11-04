// § modFnLitLeftoverValueGate302v
// vl17: the builder called with a named argument and with the argument's default omitted, each taking one arm
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk(input bit s = 1'b0);
    pk::c_t c; c.a = 2; if (s) c.b = 21; else c.b = 22; return c;
  endfunction
  localparam pk::c_t L = mk(.s(1'b1));
  localparam logic [7:0] LB = L.b;
  assign o = 1'b0;
endmodule
