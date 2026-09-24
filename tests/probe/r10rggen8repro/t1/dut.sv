// r10rggen8 t1: a gen-scope CONT-ASSIGN whose Rhs is a call to a module
// function, in a module instantiated MORE THAN ONCE.  Does every elab
// instance's actual carry the formal-typespec ref, or only the first?
module leaf #(parameter int W = 4, parameter bit ON = 1) (
  input  logic [W-1:0] a,
  input  logic [W-1:0] b,
  output logic [W-1:0] q
);
  function automatic logic [W-1:0] mix(
    logic [W-1:0] x,
    logic [W-1:0] y
  );
    return x ^ y;
  endfunction

  generate if (ON) begin : g_on
    logic [W-1:0] t;
    assign t = mix(a, b);
    assign q = t;
  end
  else begin : g_off
    assign q = '0;
  end endgenerate
endmodule

module top (
  input  logic [3:0] a,
  input  logic [3:0] b,
  output logic [3:0] q0,
  output logic [3:0] q1,
  output logic [7:0] q2
);
  leaf #(.W(4), .ON(1)) u0 (.a(a), .b(b), .q(q0));
  leaf #(.W(4), .ON(1)) u1 (.a(a), .b(b), .q(q1));
  leaf #(.W(8), .ON(1)) u2 (.a({a,a}), .b({b,b}), .q(q2));
endmodule
