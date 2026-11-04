// § fnRetLitRhsSharesDefConst273
module dut #(parameter bit PD = 0) (input logic [7:0] a, output logic [31:0] o);
  assign o = f(a);
  function automatic bit f(input logic [7:0] address);
    if (PD) return (address >= 8'h10);
    else return 1'b1;
  endfunction
endmodule
