module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [7:0] o);
  assign o = f(a);
  function automatic logic [7:0] f(logic [7:0] address);
    if (address == 0) begin
      return 8'h1;
    end
    else begin
      return f(address - 1);
    end
  endfunction

endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  m u0(.a(a), .o(o));
endmodule
