module m #(parameter bit PD = 0, parameter int P = 5) (input logic [7:0] a, output logic o);
  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return P[0];
    end
  endfunction

endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
