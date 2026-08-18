module sub(output logic [7:0] q);
  assign q = 8'h20;
endmodule
module m #(parameter bit PD = 0) (output logic o);
  sub u_s();
  assign o = f(u_s.q);
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
module dut(output logic o);
  m u0(.o(o));
endmodule
