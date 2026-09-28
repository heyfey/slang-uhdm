// § tfArgOutsideCopyOrder193
package pk;
  typedef struct packed {
    logic a;
    logic b;
  } s_t;
  parameter s_t P[2] = '{
    '{a: 1'b0, b: 1'b1},
    '{a: 1'b1, b: 1'b0}
  };
endpackage
package pk2;
  import pk::*;
  parameter int N = 2;
endpackage
module dut import pk2::*; import pk::*; (input s_t i, output logic o);
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
  assign o = f(i) ^ N[0];
endmodule
