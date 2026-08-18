module m #(parameter int W = 4) (input logic [7:0] a, output logic [W-1:0] o);
  function automatic logic [W-1:0] f(logic [7:0] address);
    return '1;
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic [3:0] o);
  m #(.W(4)) u0(.a(a), .o(o));
endmodule
