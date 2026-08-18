typedef enum logic [1:0] { Z0 = 2'd0, Z1 = 2'd1, Z3 = 2'd3 } z_t;
module m #(parameter bit PD = 0) (input logic [7:0] a, output z_t o);
  function automatic z_t f(logic [7:0] address);
    if (PD) begin
      return z_t'(address[1:0]);
    end
    else begin
      return Z3;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output z_t o);
  m u0(.a(a), .o(o));
endmodule
