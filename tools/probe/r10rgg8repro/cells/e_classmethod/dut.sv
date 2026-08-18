class C;
  function automatic logic cm(logic [7:0] address);
    if (1'b0) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
endclass
module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  C c = new();
  assign o = c.cm(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
