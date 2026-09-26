// § tfArgQualOutsideWriter176
package p;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  function automatic logic f(s_t x);
    return x.b;
  endfunction
endpackage
module dut(input p::s_t i, output logic o);
  assign o = p::f(i);
endmodule
