// r11u205 D5 d01: the only return in a case DEFAULT item (no omitted default), a constant argument
module top(output int o1, output int o2);
  function automatic int f(int a);
    case (a)
      0: f = 5;
      default: return a + 1;
    endcase
  endfunction
  assign o1 = f(3);
  assign o2 = f(0);
endmodule
