package p;
  parameter int P = 5;
endpackage
module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [7:0] o);
  function automatic logic [7:0] f(logic [7:0] address);
    if (PD) begin
      return address;
    end
    else begin
      return p::P;
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  m u0(.a(a), .o(o));
endmodule
