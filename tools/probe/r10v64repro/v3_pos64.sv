// r10v64 ARM 3 — READ-POSITION MATRIX for § elabCaPortParamPaCopy64.
// One overridden port parameter read from every position an expression can
// hold, inside a gen-if cont_assign (armed) and outside it.  MEASUREMENT ONLY.
module subV3 #(parameter int unsigned P = 4)
  (input logic c, input logic [15:0] n, output logic [15:0] y);
  localparam int unsigned W = 4;
  function automatic logic [3:0] f3(input logic [3:0] a); f3 = a ^ 4'h5; endfunction
  if (P != 0) begin : g_if
    wire [15:0] r00,r01,r02,r03,r04,r05,r06,r07,r08,r09,r10,r11,r12,r13,r14,
                r15,r16,r17,r18,r19,r20;
    assign r00 = P;                        // bare whole-Rhs
    assign r01 = W'(P);                    // cast operand
    assign r02 = P + n;                    // binop operand (net blocks reduce)
    assign r03 = -P + n;                   // unary operand
    assign r04 = P ? n : 16'd1;            // ternary CONDITION
    assign r05 = c ? P : n;                // ternary arm 1
    assign r06 = c ? n : P;                // ternary arm 2
    assign r07 = {n[11:0], P[3:0]};        // concat operand
    assign r08 = {{4{P[0]}}, n[11:0]};     // replication operand
    assign r09 = {P{1'b1}} | n;            // replication COUNT
    assign r10 = f3(P) | n;                // call argument
    assign r11 = n[P];                     // bit-select index
    assign r12 = n[P +: 2] | n;            // indexed part-select BASE
    assign r13 = n[0 +: 2] | n;            // (control) literal base
    assign r14 = n[P-1:0] | n;             // part-select bound
    assign r15 = $clog2(P) + n;            // sys-func argument
    assign r16 = (P > 2) ? n : 16'd3;      // comparison operand
    assign r17 = n << P;                   // shift amount
    assign r18 = {P, P} | n;               // two reads, one concat
    assign r19 = n & {12'd0, P[3:0]};      // nested concat
    assign r20 = c ? W'(P) : W'(P);        // cast inside ternary
    assign y = r00^r01^r02^r03^r04^r05^r06^r07^r08^r09^r10^r11^r12^r13^r14^
               r15^r16^r17^r18^r19^r20;
  end
  else begin : g_else
    assign y = n;
  end
endmodule

// Port ACTUAL / OVERRIDE ACTUAL / range-bound read positions.
module leafV3 #(parameter int unsigned Q = 4)(input [7:0] a, output b);
  assign b = |a;
endmodule
module subV3b #(parameter int unsigned P = 4)(input logic [15:0] n, output o1, output o2);
  if (P != 0) begin : g_if
    wire [P-1:0] wv;                       // range bound read
    assign wv = n[P-1:0];
    leafV3 #(.Q(P))  i_ov (.a(n[7:0]), .b(o1));   // override ACTUAL read
    leafV3 #(.Q(4))  i_pa (.a(n[P +: 8]), .b(o2)); // port ACTUAL select base
  end
  else begin : g_else assign o1 = 1'b0; assign o2 = 1'b0; end
endmodule

module topV3(input logic c, input logic [15:0] n);
  localparam int         SI = 1 * 2;
  localparam bit [3:0]   SH = 4'h2;
  localparam bit [3:0]   SB = 4'b0010;
  wire [15:0] y1,y2,y3,y4;
  wire b11,b12,b21,b22,b31,b32;
  subV3 #(.P(2))    i_dec (c,n,y1);
  subV3 #(.P(SH))   i_hex (c,n,y2);
  subV3 #(.P(SB))   i_bin (c,n,y3);
  subV3 #(.P(SI))   i_exp (c,n,y4);
  subV3b #(.P(2))   j_dec (n,b11,b12);
  subV3b #(.P(SH))  j_hex (n,b21,b22);
  subV3b #(.P(SB))  j_bin (n,b31,b32);
endmodule
