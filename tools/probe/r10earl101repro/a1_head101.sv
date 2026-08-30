// r10earl101 a1_head101 -- THE HEAD, reduced.  A faithful miniature of
// sha2.sv:27: a package scalar typedef, a wildcard import, and
// `output sha_word_t [7:0] digest` on a submodule that the top instantiates,
// so the DEF listing and the ELABORATED instance both carry the port.
//
// golden, measured on Earlgrey and reproduced here:
//   D work@a1sub101                 PORT o_digest  ts>e  p1h101::word_t
//   E work@a1_head101.u_sub         PORT o_digest  ts>e  word_t
// both aliased to the QUALIFIED listing object.
package p1h101;
  localparam int NumWords = 8;
  typedef logic [31:0] word_t;
  typedef struct packed {
    word_t       data;
    logic [3:0]  mask;
  } fifo_t;
endpackage

module a1sub101
  import p1h101::*;
(
  input  logic                clk,
  input  fifo_t               i_fifo,
  output word_t [NumWords-1:0] o_digest
);
  word_t [NumWords-1:0] acc;
  always_ff @(posedge clk) acc <= {acc[NumWords-2:0], i_fifo.data};
  assign o_digest = acc;
endmodule

module a1_head101 (input logic clk);
  p1h101::fifo_t                    w_fifo;
  p1h101::word_t [p1h101::NumWords-1:0] w_digest;
  a1sub101 u_sub (.clk(clk), .i_fifo(w_fifo), .o_digest(w_digest));
endmodule
