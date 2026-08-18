typedef enum int { E_OFF = 0, E_ON = 1 } e_t;
module m #(parameter e_t A = E_ON) (input logic [7:0] a, output logic o);
  function automatic logic f(logic [7:0] address);
    if (A == E_ON) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m #(.A(E_OFF)) u0(.a(a), .o(o));
endmodule
