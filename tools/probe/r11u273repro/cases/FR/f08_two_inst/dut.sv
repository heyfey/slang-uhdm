// § fnRetLitRhsSharesDefConst273
module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [31:0] o);
  assign o = f(a);
  function automatic bit f(input logic [7:0] address);
    if (PD) return (address >= 8'h10);
    else return 1'b1;
  endfunction
endmodule
module dut(input logic [7:0] a, output logic [31:0] o1, output logic [31:0] o2);
  m u0(.a(a), .o(o1));
  m u1(.a(a), .o(o2));
endmodule
