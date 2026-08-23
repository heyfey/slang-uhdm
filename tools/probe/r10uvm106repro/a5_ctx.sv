// a5: contexts that reuse the constant (cast size, concat, class param port)
module a5_cast;
  parameter W = 'h8;
  localparam logic [7:0] X = W'(3);
  initial $display(X);
endmodule
class a5_pc #(parameter P = 'h4);
  function int f(); return P; endfunction
endclass
module a5_top;
  a5_cast c1();
  a5_pc #('h9) o1;
  initial $display(o1 == null);
endmodule
