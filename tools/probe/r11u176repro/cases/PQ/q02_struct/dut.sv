// § tfArgQualOutsideWriter176
package p;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
endpackage
module dut(input p::s_t i, output logic o);
  function automatic logic f(p::s_t x);
    return x.b;
  endfunction
  assign o = f(i);
endmodule
