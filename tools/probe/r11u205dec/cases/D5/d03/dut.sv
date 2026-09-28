// r11u205 D5 d03: the default item assigns the function name, the explicit items do not match
module top(output int o1);
  function automatic int f(int a);
    f = 1;
    case (a)
      0: f = 2;
      default: f = 4;
    endcase
  endfunction
  assign o1 = f(3);
endmodule
