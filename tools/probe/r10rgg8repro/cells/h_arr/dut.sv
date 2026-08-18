module m #(parameter bit PD = 0) (input logic [7:0] a[4], input int idx, output logic o);
  assign o = f(a[idx]);
  function automatic logic f(
    logic [7:0] address
  );
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
endmodule
module dut(input logic [7:0] a[4], input int idx, output logic o);
  m u0(.a(a), .idx(idx), .o(o));
endmodule
