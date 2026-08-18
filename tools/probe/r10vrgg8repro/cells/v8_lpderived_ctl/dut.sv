module m #(parameter int A = 1) (input logic [7:0] a, output logic o);
  localparam int B = A;
  function automatic logic f(logic [7:0] address);
    if (B) begin
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
endmodule
