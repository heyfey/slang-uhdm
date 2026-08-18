module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [7:0] o);
  localparam int LP = 9;
  function automatic logic [7:0] f(logic [7:0] address);
    if (PD) begin
      return address;
    end
    else begin
      return LP;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  m u0(.a(a), .o(o));
endmodule
