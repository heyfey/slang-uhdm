// § fnRetLitRhsSharesDefConst273
package pk;
  parameter bit PD = 0;
  function automatic bit f(input logic [7:0] address);
    if (PD) return (address >= 8'h10);
    else return 1'b1;
  endfunction
endpackage
module m (input logic [7:0] a, output logic [31:0] o);
  assign o = pk::f(a);
endmodule
module dut(input logic [7:0] a, output logic [31:0] o);
  m u0(.a(a), .o(o));
endmodule
