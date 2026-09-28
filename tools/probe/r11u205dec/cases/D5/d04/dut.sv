// r11u205 D5 d04: unique case without default, no item taken
module top(output int o1);
  function automatic int f(int a);
    f = 6;
    case (a)
      0: f = 2;
      1: f = 3;
    endcase
  endfunction
  assign o1 = f(3);
endmodule
