package pk;
  function automatic bit g(); return 1'b1; endfunction
endpackage
module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (pk::g()) ? 42 : 7;
endmodule
module top;
  m #(.P(0)) u_a();
endmodule
