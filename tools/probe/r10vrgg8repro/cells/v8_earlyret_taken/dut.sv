module m #(parameter bit PD = 1) (input logic [7:0] a, output logic o);
  function automatic logic f(logic [7:0] address);
    if (PD) return '1;
    return address[0];
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
