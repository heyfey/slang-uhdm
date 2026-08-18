module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  function automatic logic g(logic [7:0] x);
    return f(x);
  endfunction
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return '0;
    end
    else begin
      return g(address);
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
