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
// r10v108 micro — GEN-SCOPE ONLY.  MEASUREMENT ONLY.
module mg108 #(parameter bit R = 0) (output logic o); assign o = R; endmodule
module m_gen108 import v108p::*; (output logic [2:0] o);
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi = gi + 1) begin : gfor
      mg108 #(.R(RSP)) i_g (.o(o[gi]));
    end
    if (1) begin : gif
      mg108 #(.R(RSP)) i_h (.o(o[2]));
    end
  endgenerate
endmodule
