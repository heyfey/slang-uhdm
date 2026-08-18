module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    localparam logic K = '1;
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return K;
    end
  endfunction

endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
