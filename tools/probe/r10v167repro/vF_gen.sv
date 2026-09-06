// r10v167 arm F - the SECOND shell mechanism (an unresolvable `::` name in an
// UNINSTANTIATED generate branch) and the DEF-view GENERATE-PROCESS home,
// where our emitter does NOT link the callee (linked4 == false).
module gm167 #(parameter int P = 1) (input logic clk, output int o);
  int r;
  function int gf167(int a, int b = 0, int c = 5);
    return a + b + c;
  endfunction
  task gt167(int a, int b = 0);
    r = a + b;
  endtask

  generate
    if (P == 1) begin : live
      always_comb begin
        o = gf167(1);
      end
      always_comb begin
        o = gf167(.a(1), .c(9));
      end
    end
    else begin : dead
      always_comb begin
        o = gf167(nosuch167::val);
      end
      always_comb begin
        o = gf167(.a(nosuch167::val), .c(9));
      end
      always_comb begin
        o = gf167(.c(9), .a(nosuch167::val));
      end
      always_comb begin
        o = gf167(nosuch167::val, 2, );
      end
      always @(posedge clk) begin
        gt167(nosuch167::val);
      end
    end
  endgenerate
endmodule

module tf167 (input logic clk, output int o1);
  gm167 #(.P(1)) g1 (.clk(clk), .o(o1));
endmodule
