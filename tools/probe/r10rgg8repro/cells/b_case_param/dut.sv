module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    case (PD)
      1'b0: return '1;
      default: return (address >= 8'h10);
    endcase
  endfunction

endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
