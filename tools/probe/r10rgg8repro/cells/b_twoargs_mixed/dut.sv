module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  assign o = f(a, 8'h3);
  function automatic logic f(logic [7:0] address, logic [7:0] k);
    if (PD) begin
      return (address >= k);
    end
    else begin
      return '1;
    end
  endfunction

endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
