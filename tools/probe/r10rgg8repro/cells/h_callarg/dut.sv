module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  assign o = f(g(a));
  function automatic logic [7:0] g(logic [7:0] x);
    return x + 1;
  endfunction
  function automatic logic f(
    logic [7:0] address
  );
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
