package p;
  function automatic logic pf(logic [7:0] x);
    return '1;
  endfunction
endpackage
module m (input logic [7:0] a, output logic o);
  assign o = p::pf(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
