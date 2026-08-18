module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [7:0] o);
  function automatic logic [7:0] f(logic [7:0] address);
    logic [7:0] t = 8'd7;
    if (PD) begin
      return address;
    end
    else begin
      return t;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  m u0(.a(a), .o(o));
endmodule
