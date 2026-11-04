// § fnRetLitRhsSharesDefConst273
module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [31:0] o);
  assign o = f(a);
  function automatic int f(
    logic [7:0] address
  );
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return 5;
    end
  endfunction
endmodule
module dut(input logic [7:0] a, output logic [31:0] o);
  m u0(.a(a), .o(o));
endmodule
