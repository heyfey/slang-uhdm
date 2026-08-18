module m #(parameter bit PD = 0) (input logic [7:0] a, output real o);
  function automatic real f(logic [7:0] address);
    if (PD) begin
      return address;
    end
    else begin
      return '1;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output real o);
  m u0(.a(a), .o(o));
endmodule
