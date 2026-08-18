module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  logic ex;
  assign o = f(a, ex);
  function automatic logic f(logic [7:0] address, output logic q);
    q = '0;
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction

endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
