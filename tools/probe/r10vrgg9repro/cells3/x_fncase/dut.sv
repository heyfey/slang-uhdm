module m #(
  parameter bit P = 1
)();
  logic [7:0] vec;
  logic [7:0] arr[2];
  function automatic int fc(int n); case (n) 0: return 9; 2: return 21; default: return 3; endcase endfunction

  assign arr[0] = (P) ? fc(2) : 7;
endmodule
module top;
  m u_a();
endmodule
