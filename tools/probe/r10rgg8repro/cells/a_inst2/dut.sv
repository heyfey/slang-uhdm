module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  assign o = f(a);
  function automatic logic f(
    logic [7:0] address
  );
    if (PD) begin
      logic [7:0] b;
      b = 8'h10;
      return (address >= b);
    end
    else begin
      return '1;
    end
  endfunction

endmodule
module dut(input logic [7:0] a, output logic o);
  logic [1:0] w;
  m u0(.a(a), .o(w[0]));
  m u1(.a(a), .o(w[1]));
  assign o = |w;
endmodule
