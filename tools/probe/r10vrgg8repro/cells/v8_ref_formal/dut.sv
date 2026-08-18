module m (input logic [7:0] a, output logic o);
  function automatic logic f(const ref logic [7:0] address);
    return '1;
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
