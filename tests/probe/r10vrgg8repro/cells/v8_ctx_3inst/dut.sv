module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic [2:0] o);
  m           u0(.a(a), .o(o[0]));
  m #(.PD(0)) u1(.a(a), .o(o[1]));
  m #(.PD(1)) u2(.a(a), .o(o[2]));
endmodule
