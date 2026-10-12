// § castPatTagKeyLocThroughParens302
// vc06: a cast-wrapped pattern inside a for-generate continuous assignment and a function case item
package p;
  typedef struct packed { logic [7:0] n; logic [7:0] h; } cfg_t;
endpackage
module dut (input logic [1:0] s, output p::cfg_t o [2], output p::cfg_t q);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = p::cfg_t'('{n: i, h: 8'h3});
  end
  function automatic p::cfg_t f(input logic [1:0] k);
    case (k)
      2'd0: return p::cfg_t'('{n: 1, h: 2});
      default: return p::cfg_t'('{n: 5, h: 6});
    endcase
  endfunction
  assign q = f(s);
endmodule
