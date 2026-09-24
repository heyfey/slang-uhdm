module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  assign o = f(a);
  generate
    if (PD) begin : g1
      logic z;
    end
  endgenerate
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
  m u0(.a(a), .o(o));
endmodule
