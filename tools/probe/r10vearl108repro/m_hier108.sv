package v108p;
  typedef struct packed {
    logic [1:0] a;
    logic [1:0] b;
    logic [1:0] c;
    logic       d;
  } rsp_t;
  parameter rsp_t RSP  = '{a: 2'b01, b: 2'b01, c: 2'b10, d: 1'b0};
  typedef struct packed { logic [31:0] hi; logic [31:0] mid; logic [15:0] lo; } big_t;
  parameter big_t BIG = '{hi: 32'hdead_beef, mid: 32'h1234_5678, lo: 16'habcd};
  typedef struct packed { logic [3:0] q; logic [1:0] r; } inner_t;
  typedef struct packed { inner_t n; logic [2:0] t; } outer_t;
  parameter outer_t NEST = '{n: '{q: 4'ha, r: 2'b01}, t: 3'b101};
endpackage
// r10v108 micro — the ACTUAL is a struct localparam of an ENCLOSING generate
// block, and a second one reached through a package chain.
module mh108 #(parameter bit R = 0) (output logic o); assign o = R; endmodule
module m_hier108 import v108p::*; (output logic [1:0] o);
  generate
    if (1) begin : gb
      localparam v108p::rsp_t GLOC = '{a: 2'b11, b: 2'b10, c: 2'b01, d: 1'b1};
      mh108 #(.R(GLOC)) i_x (.o(o[0]));
    end
  endgenerate
  mh108 #(.R(v108p::RSP)) i_y (.o(o[1]));
endmodule
