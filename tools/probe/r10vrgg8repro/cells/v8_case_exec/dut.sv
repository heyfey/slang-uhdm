module m #(parameter int PD = 0) (input logic [7:0] a, output logic o);
  function automatic logic f(logic [7:0] address);
    case (PD)
      0: return '1;
      default: return address[0];
    endcase
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
