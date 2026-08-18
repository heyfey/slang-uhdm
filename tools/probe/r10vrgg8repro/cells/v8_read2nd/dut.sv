module m #(parameter bit PD = 0) (input logic [7:0] a, input logic [7:0] b, output logic o);
  function automatic logic f(logic [7:0] x, logic [7:0] y);
    if (PD) begin
      return x[0];
    end
    else begin
      return y[0];
    end
  endfunction
  assign o = f(a, b);
endmodule
module dut(input logic [7:0] a, input logic [7:0] b, output logic o);
  m u0(.a(a), .b(b), .o(o));
endmodule
