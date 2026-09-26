// § tfArgQualOutsideWriter176
package p;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
endpackage
module dut import p::*; (input s_t i, output logic o);
  function automatic logic f(s_t x);
    return x.b;
  endfunction
  assign o = f(i);
endmodule
