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
// r10v108 micro — INTERFACE with a STRUCT formal (the LANDED precedent).
interface mis108 #(parameter v108p::rsp_t R = '{default: 0}) (); logic [6:0] x; assign x = R; endinterface
module m_ifs108 import v108p::*; (output logic [6:0] o);
  mis108 #(.R(RSP)) i_if ();
  assign o = i_if.x;
endmodule
