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
interface ifc;
  logic [1:0] w;
  function automatic logic f(pk::s_t x);
    return x.a;
  endfunction
endinterface
module dut import pk::*; (input s_t i, output logic o);
  ifc u_if ();
  assign u_if.w = i;
  assign o = u_if.w[0];
endmodule
