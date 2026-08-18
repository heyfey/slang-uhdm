module m #(parameter bit [1:0] A = 2'd3) (input logic [7:0] a, output logic o);
  function automatic logic f(logic [7:0] address);
    if ((A + 2'd1) != 2'd0) begin
      return '1;
    end
    else begin
      return (address >= 8'h10);
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
