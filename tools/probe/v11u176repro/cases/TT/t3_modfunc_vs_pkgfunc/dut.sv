// § tdKeyKeepsUnresolved176v
module dut(input pa::s_t i, output logic o, p);
  import pa::*;
  function automatic logic g(s_t v);
    return v.x[0];
  endfunction
  assign o = pb::f(i);
  assign p = g(i);
endmodule
