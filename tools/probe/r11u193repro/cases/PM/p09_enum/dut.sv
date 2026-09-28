// § tfArgOutsideCopyOrder193
package pk;
  typedef enum logic [1:0] {A0, A1, A2} e_t;
  parameter e_t P[2] = '{A0, A2};
endpackage
module dut import pk::*; (input e_t i, output logic o);
  function automatic logic f(pk::e_t x);
    return x == A1;
  endfunction
  assign o = f(i);
endmodule
