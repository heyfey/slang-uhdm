module m #(parameter int N = 4) (input logic [7:0] a, output logic o);
  function automatic logic f(logic [7:0] address);
    for (int i = 0; i < N; i++) begin
      return '1;
    end
    return '0;
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
