// r10vearl70 adversarial arm: operation kinds and nesting within both bounds.
package vo70_pkg;
  parameter int P = 16;
  parameter int Q = 4;
  parameter int A = P;
  localparam int L = Q + 12;
endpackage

module vo70_leaf(
  input [127:0] p0, p1, p2, p3, p4, p5, p6, p7, p8, p9,
  input [127:0] p10, p11, p12, p13, p14, p15, p16, p17
);
endmodule

module vo70_mid import vo70_pkg::*; (input [255:0] sig);
  for (genvar i = 0; i < 2; i++) begin: g
    vo70_leaf u(
      .p0(sig[P+1:0]),
      .p1(sig[1+P:0]),
      .p2(sig[P*2-1:0]),
      .p3(sig[(P/2)+7:0]),
      .p4(sig[(P<<1)-1:0]),
      .p5(sig[(P>>1)+7:0]),
      .p6(sig[(P|Q)-1:0]),
      .p7(sig[(P&31)-1:0]),
      .p8(sig[(P^Q)+3:0]),
      .p9(sig[(P>Q ? P : Q)-1:0]),
      .p10(sig[(P==16 ? P : Q)-1:0]),
      .p11(sig[(+P)-1:0]),
      .p12(sig[(~P)+32:0]),
      .p13(sig[int'(P)-1:0]),
      .p14(sig[((P+1)-1)-1:0]),
      .p15(sig[A-1:0]),
      .p16(sig[L-1:0]),
      .p17(sig[P+Q-1:Q-1])
    );
  end
endmodule

module vo70_top(input [255:0] sig);
  vo70_mid u(.sig(sig));
endmodule
