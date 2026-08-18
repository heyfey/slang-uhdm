module m (input logic [7:0] a, output logic o);
  function automatic logic h();
    return '1;
  endfunction
  function automatic logic g(logic [7:0] x);
    return h();
  endfunction
  function automatic logic f(logic [7:0] address);
    return g(address);
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
