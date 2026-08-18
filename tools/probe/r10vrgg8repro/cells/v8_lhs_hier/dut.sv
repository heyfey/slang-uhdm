module s(output logic q);
endmodule
module m (input logic [7:0] a, output logic o);
  function automatic logic f(logic [7:0] address);
    return '1;
  endfunction
  s u_s(.q());
  assign u_s.q = f(a);
  assign o = u_s.q;
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
