// r11u205 B3 b03: a vector return and vector formals, named omission
module top(output logic [7:0] o1, output logic [7:0] o2);
  function automatic logic [7:0] f(logic [7:0] a, logic [7:0] b = 8'h10);
    return a | b;
  endfunction
  assign o1 = f(.a(8'h01));
  assign o2 = f(.b(8'h02), .a(8'h01));
endmodule
