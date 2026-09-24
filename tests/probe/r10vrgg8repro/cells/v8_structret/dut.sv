typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
module m #(parameter bit PD = 0) (input logic [7:0] a, output s_t o);
  function automatic s_t f(logic [7:0] address);
    if (PD) begin
      return s_t'(address);
    end
    else begin
      return '1;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output s_t o);
  m u0(.a(a), .o(o));
endmodule
