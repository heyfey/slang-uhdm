module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    logic r;
    r = '0;
    if (PD) begin
      r = (address >= 8'h10);
    end
    else begin
      for (int i = 0; i < 4; i++) begin
        r = '1;
      end
    end
    return r;
  endfunction

endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
