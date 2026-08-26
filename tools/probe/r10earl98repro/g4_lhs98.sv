// r10earl98 g4 -- THE Lhs SHAPE AXIS and the HOME AXIS.
// `writeCont_assign`'s bind-and-clone gate is `lhs->UhdmType() == uhdmref_obj`:
// a SELECT / member Lhs is not a bare ref_obj, so § genCaSelLhsDeepBindGenLocal23
// must keep its bindings even when the base name is shadowed one module up.
module l1leaf98 (input logic clk, input logic [3:0] a, output logic o);
  if (1) begin : gen_if
    logic [3:0] w1, w2;
    logic       t_bare;    // BARE ref Lhs   -> clone path
    logic [3:0] t_esel;    // element select Lhs
    logic [3:0] t_rsel;    // range select Lhs
    assign t_bare    = (w1 == w2);
    assign t_esel[0] = (w1 != w2);
    assign t_rsel[1:0] = {(w1 == w2), (w1 != w2)};
    assign o = t_bare ^ t_esel[0] ^ (^t_rsel);
    always_ff @(posedge clk) begin
      w1 <= a;
      w2 <= w1;
    end
  end
  for (genvar gi = 0; gi < 2; gi++) begin : gen_for
    logic [3:0] f1, f2;
    logic       t_for;     // a FOR-generate body
    assign t_for = (f1 == f2);
    always_ff @(posedge clk) begin
      f1 <= a;
      f2 <= f1;
    end
  end
  if (1) begin : gen_o
    if (1) begin : gen_i
      logic [3:0] n1, n2;
      logic       t_nest;  // a NESTED gen block
      assign t_nest = (n1 == n2);
      always_ff @(posedge clk) begin
        n1 <= a;
        n2 <= n1;
      end
    end
  end
endmodule

interface l1if98 (input logic clk);
  logic t_ifc;
  if (1) begin : gen_ifc
    logic [3:0] i1, i2;
    logic       t_ifgen;   // a gen scope inside an INTERFACE
    assign t_ifgen = (i1 == i2);
  end
endinterface

module g4_lhs98 (input logic clk, input logic [3:0] a, output logic o);
  logic t_bare, t_for, t_nest, t_ifgen;
  logic [3:0] t_esel, t_rsel;
  assign t_bare = 1'b0; assign t_esel = '0; assign t_rsel = '0;
  assign t_for = 1'b0;  assign t_nest = 1'b0; assign t_ifgen = 1'b0;
  l1if98 u_if (.clk(clk));
  l1leaf98 u_a (.clk(clk), .a(a), .o(o));
  l1leaf98 u_b (.clk(clk), .a(a), .o());
endmodule
