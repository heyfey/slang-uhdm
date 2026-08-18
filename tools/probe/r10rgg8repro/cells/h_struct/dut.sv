typedef struct packed { logic [7:0] addr; } s_t;
module m #(parameter bit PD = 0) (input s_t sv, output logic o);
  assign o = f(sv.addr);
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
module dut(input s_t sv, output logic o);
  m u0(.sv(sv), .o(o));
endmodule
