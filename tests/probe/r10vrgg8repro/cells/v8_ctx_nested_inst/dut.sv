module inner #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
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
module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  inner #(.PD(PD)) u_in(.a(a), .o(o));
endmodule
module dut(input logic [7:0] a, output logic [1:0] o);
  m #(.PD(0)) u0(.a(a), .o(o[0]));
  m #(.PD(1)) u1(.a(a), .o(o[1]));
endmodule
