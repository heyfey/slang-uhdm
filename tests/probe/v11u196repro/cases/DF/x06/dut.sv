// § dfltArgExecutedPathEval196v: a read in a case statement's selected arm, in a while loop that runs, inside a begin-end block (all kept)
module top(output int o1, output int o2, output int o3);
  function automatic int f(int a, int b = 2);
    case (a)
      1: return b;
      default: return a;
    endcase
  endfunction
  function automatic int g(int a, int b = 2);
    int r = 0;
    while (r < a) r = r + b;
    return r;
  endfunction
  function automatic int h(int a, int b = 2);
    begin
      return a * b;
    end
  endfunction
  assign o1 = f(1);
  assign o2 = g(3);
  assign o3 = h(4);
endmodule
