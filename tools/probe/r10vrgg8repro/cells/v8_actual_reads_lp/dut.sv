module m #(parameter bit PD = 1) (input logic [7:0] a, output logic o);
  localparam logic [7:0] LP = 8'd32;
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'd16);
    end
    else begin
      return '1;
    end
  endfunction
  assign o = f(LP);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
