// c1: the READ-POSITION truth table for a TYPED packed-vector parameter.
// Every Cn is read in exactly ONE position.  Golden's answer per cell is the
// law; ours is the thing under test.
module c1_sub #(parameter logic [31:0] S = 'h0) (output logic [31:0] y);
  assign y = S;
endmodule

module c1_earl49 #(
  parameter int           W   = 32,
  parameter logic [W-1:0] C1  = 'h0,  // OR with a concat holding a net
  parameter logic [W-1:0] C2  = 'h0,  // AND with a bare net
  parameter logic [W-1:0] C3  = 'h0,  // ADD with a bare net
  parameter logic [W-1:0] C4  = 'h0,  // == against a net, inside a ternary cond
  parameter logic [W-1:0] C5  = 'h0,  // net OP param (param on the RIGHT)
  parameter logic [W-1:0] C6  = 'h0,  // select beside a net inside a concat
  parameter logic [W-1:0] C7  = 'h0,  // procedural read only
  parameter logic [W-1:0] C8  = 'h0,  // ternary BRANCH, sibling is a net
  parameter logic [W-1:0] C9  = 'h0,  // read only as an instance override
  parameter logic [W-1:0] C10 = 'h0,  // never read
  parameter logic [W-1:0] C11 = 'h0,  // part-select IS the whole RHS
  parameter logic [W-1:0] C12 = 'h0   // bitwise OR with a net inside a for-generate
) (
  input  logic         c,
  input  logic [W-1:0] n,
  output logic [W-1:0] o1, o2, o3, o4, o5, o6, o8, o11, o12, o9,
  output logic [W-1:0] r7
);
  assign o1  = C1 | {{(W-4){1'b0}}, n[3:0]};
  assign o2  = C2 & n;
  assign o3  = C3 + n;
  assign o4  = (C4 == n) ? n : '0;
  assign o5  = n & C5;
  assign o6  = {C6[3:0], n[W-5:0]};
  always_comb r7 = C7 | n;
  assign o8  = c ? C8 : n;
  c1_sub #(.S(C9)) u_sub (.y(o9));
  assign o11 = C11[W-1:0];
  for (genvar k = 0; k < 32; k++) begin : gen_c
    assign o12[k] = C12[k] | n[k];
  end
endmodule
