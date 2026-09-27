// § tfArgDefTopSplit176
package p;
  typedef enum logic [1:0] {R, G, B} col_e;
  task automatic t(output col_e o);
    o = G;
  endtask
endpackage
module top(output int x);
  function automatic int h(input p::col_e c = p::B);
    return int'(c);
  endfunction
  p::col_e v;
  initial begin p::t(v); end
  assign x = h();
endmodule
