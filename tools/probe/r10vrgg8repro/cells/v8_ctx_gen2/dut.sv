module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [1:0] o);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = f(a);
  end
endmodule
module dut(input logic [7:0] a, output logic [1:0] o);
  m u0(.a(a), .o(o));
endmodule
