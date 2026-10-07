// § fnRetLitRhsSharesDefConst273
module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [31:0] o);
  typedef logic [7:0] t8_t;
  typedef enum logic [7:0] { EZ = 8'd0, EA = 8'd42 } e_t;
  assign o = f(a);
  function automatic t8_t f(input logic [7:0] address);
    if (PD) return t8_t'(address);
    else return 8'd42;
  endfunction
endmodule
module dut(input logic [7:0] a, output logic [31:0] o);
  m u0(.a(a), .o(o));
endmodule
