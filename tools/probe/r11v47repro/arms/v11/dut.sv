class cls #(parameter type it_t = struct packed { logic [7:0] x; logic [3:0] y; });
  localparam it_t I = '{x: 8'd1, y: 4'd2};
  function automatic int get(); return I.y; endfunction
endclass
module dut;
  int z;
  cls #() c;
  initial begin c = new(); z = c.get(); end
endmodule
