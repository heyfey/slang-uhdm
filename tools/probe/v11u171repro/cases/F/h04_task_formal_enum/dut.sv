// § tdMoveCarriesFile172
package pb;
  import pa::*;
  function automatic logic f(e_t v, input logic q);
    return (v == B) ^ q;
  endfunction
endpackage
module dut(input pa::e_t i, output logic o);
  assign o = pb::f(i, 1'b1);
endmodule
