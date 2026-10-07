// § fnRetLitRhsSharesDefConst273
module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [31:0] o, output logic [31:0] p);
  assign o = f(a);
  assign p = f(~a);
  function automatic bit f(input logic [7:0] address);
    if (PD) return (address >= 8'h10);
    else return 1'b1;
  endfunction
endmodule
module dut(input logic [7:0] a, output logic [31:0] o, output logic [31:0] p);
  m u0(.a(a), .o(o), .p(p));
endmodule
