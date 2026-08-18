module m (input logic [7:0] a, output logic o);
  parameter int A = 1;
  function automatic logic f(logic [7:0] address);
    if (A) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
  defparam u0.A = 0;
endmodule
