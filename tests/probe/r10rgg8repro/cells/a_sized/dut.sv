module m #(parameter bit PD = 0, parameter int P = 5) (input logic [7:0] a, output logic [31:0] o);
  assign o = f(a);
  function automatic logic [7:0] f(
    logic [7:0] address
  );
    if (PD) begin
      logic [7:0] b;
      b = 8'h10;
      return (address >= b);
    end
    else begin
      return 8'h2a;
    end
  endfunction

endmodule
module dut(input logic [7:0] a, output logic [31:0] o);
  m u0(.a(a), .o(o));
endmodule
