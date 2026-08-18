module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [3:0][7:0] o);
  function automatic logic [3:0][7:0] f(logic [7:0] address);
    if (PD) begin
      return {4{address}};
    end
    else begin
      return '1;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic [3:0][7:0] o);
  m u0(.a(a), .o(o));
endmodule
