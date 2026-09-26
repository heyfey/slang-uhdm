// § tfArgQualOutsideWriter176
package p;
  typedef union packed { logic [2:0] a; logic [2:0] b; } u_t;
endpackage
module dut(input p::u_t i, output logic o);
  function automatic logic f(p::u_t x);
    return x.a[0];
  endfunction
  assign o = f(i);
endmodule
