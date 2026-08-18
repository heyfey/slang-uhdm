module m (input logic [7:0] a, input logic [7:0] b, output logic o);
  function automatic logic f(logic [7:0] x, logic [7:0] y);
    return '1;
  endfunction
  assign o = f(a, b);
endmodule
module dut(input logic [7:0] a, input logic [7:0] b, output logic o);
  m u0(.a(a), .b(b), .o(o));
endmodule
