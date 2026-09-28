// r11u205 D5 d02: a case whose taken item is an explicit one and a default beside it
module top(output int o1);
  function automatic int f(int a);
    case (a)
      3: return 7;
      default: return 9;
    endcase
  endfunction
  assign o1 = f(3);
endmodule
