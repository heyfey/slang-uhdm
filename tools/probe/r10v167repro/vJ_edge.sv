// r10v167 arm J - the remaining faces: a shelled call with EMPTY PARENS (the
// RECEIVER is what is bad), a DPI import WITH defaults, a hierarchical call
// from a generate process, and system tf calls as the NO-DEFAULT control.
package pj167;
  import "DPI-C" function int dpj167(input int a, input int b);
  class snk167;
    int r;
    function int allj167(int a = 1, int b = 2);
      return a + b;
    endfunction
    function int onej167(int a, int b = 3);
      return a + b;
    endfunction
  endclass
  class shJ167 #(type T167 = int);
    snk167 s;
    T167   bad;
    int r;
    string t;
    function void goJ();
      r = s.allj167();                 // clean empty parens
      r = bad.allj167();               // bad RECEIVER, EMPTY PARENS
      r = bad.onej167(1);              // bad RECEIVER, one written
      r = s.onej167(T167::nm167);      // bad ARGUMENT (control)
      r = dpj167(1, 2);
      r = dpj167(T167::nm167, 2);
      t = $sformatf("%0d", 7);
      t = $sformatf("%0d", T167::nm167);
      $display("d %0d", T167::nm167);
    endfunction
  endclass
endpackage

module hm167 #(parameter int P = 1) (input logic clk, output int o);
  generate
    if (P == 1) begin : jlive
      always_comb o = jt167.hj167(1);
    end
    else begin : jdead
      always_comb o = jt167.hj167(nosuch167::val);
      always_comb o = jt167.hj167(.a(nosuch167::val), .c(9));
    end
  endgenerate
endmodule

module jt167 (input logic clk, output int o1);
  function automatic int hj167(int a, int b = 5, int c = 6);
    return a + b + c;
  endfunction
  hm167 #(.P(1)) h1 (.clk(clk), .o(o1));
endmodule
