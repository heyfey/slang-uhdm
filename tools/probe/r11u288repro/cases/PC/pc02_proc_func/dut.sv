// § parenCastReadsCastSyntax288 — parenthesized casts in processes, a function, a task, conditions and case items
module top(input logic [7:0] x, input logic [1:0] s, output logic [31:0] y, z, w);
  typedef logic [3:0] b4_t;
  function automatic int f(input logic [7:0] a);
    return (int'(a)) * 2;
  endfunction
  task automatic t(output int r);
    r = (shortint'(x)) - 1;
  endtask
  always_comb begin
    y = (int'(x)) ? 32'd1 : 32'd2;
    if ((int'(s)) == 1) z = (8'(x));
    else z = f(x);
    case ((int'(s)))
      (int'(2'd1)): w = 1;
      default: w = (b4_t'(x));
    endcase
  end
  initial t(y);
endmodule
