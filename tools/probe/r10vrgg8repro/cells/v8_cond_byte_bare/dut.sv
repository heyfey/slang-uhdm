module m #(parameter byte A = 0) (input logic [7:0] a, output logic o);
  function automatic logic f(logic [7:0] address);
    if (A) begin
      return address[0];
    end
    else begin
      return '1;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
