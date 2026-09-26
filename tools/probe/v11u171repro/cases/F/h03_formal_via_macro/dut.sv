// § tdMoveCarriesFile172
`define T pa::s_t
package pb;
  function automatic logic f(`T v);
    return v.y;
  endfunction
endpackage
module dut(input pa::s_t i, output logic o);
  assign o = pb::f(i);
endmodule
