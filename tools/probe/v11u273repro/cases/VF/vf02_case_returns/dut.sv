// § fnRetLitRhsSharesDefConst273
module dut (output int o [3]);
  function automatic int f(input int x);
    case (x)
      0: return 5;
      1: return 6;
      default: return 7;
    endcase
  endfunction
  assign o[0] = f(0);
  assign o[1] = f(1);
  assign o[2] = f(2);
endmodule
