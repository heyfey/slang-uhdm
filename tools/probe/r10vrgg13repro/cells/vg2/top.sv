module mid #(
  parameter int P = 8'h07
)(
  output logic o
);
  localparam int Q = 4'b0110;
  function automatic bit [P-1:0][15:0] flp(bit signed [31:0] n);
    bit [P-1:0][15:0] list;
    list = '0;
    list[0] = 16'(n);
    return list;
  endfunction

  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0];
endmodule

module top;
  logic o1,o2,o3,o4,o5,o6;
  mid #(.P(2))        u1 (.o(o1));
  mid #(.P(8'h03))    u2 (.o(o2));
  mid #(.P(4'b0101))  u3 (.o(o3));
  mid #(.P(3'o5))     u4 (.o(o4));
  mid #(.P(1+3))      u5 (.o(o5));
  mid                 u6 (.o(o6));
endmodule
