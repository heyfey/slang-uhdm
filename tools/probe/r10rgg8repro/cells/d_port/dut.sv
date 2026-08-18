module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  logic q;
  n u1(.x(f(a)), .y(q));
  assign o = q;
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
module n(input logic x, output logic y);
  assign y = x;
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
