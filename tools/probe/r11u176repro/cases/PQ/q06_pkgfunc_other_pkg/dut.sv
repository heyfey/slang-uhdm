// § tfArgQualOutsideWriter176
package p;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
endpackage
package q;
  function automatic logic f(p::s_t v);
    return v.b;
  endfunction
endpackage
module dut(input p::s_t i, output logic o);
  assign o = q::f(i);
endmodule
