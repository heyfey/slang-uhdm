// r10earl107 grid arm g2_form107 -- MEASUREMENT ONLY.
// THE FILL-SPELLING x MEMBER-WIDTH matrix at a PORT high_conn.
package pg2_107;
  typedef struct packed {
    logic [0:0]  w1;
    logic [2:0]  w3;
    logic [7:0]  w8;
    logic [31:0] w32;
    logic [63:0] w64;
    logic [64:0] w65;
  } wide_t;
  parameter wide_t W_ONES  = '{ w1:'1, w3:'1, w8:'1, w32:'1, w64:'1, w65:'1 };
  parameter wide_t W_ZERO  = '{ w1:'0, w3:'0, w8:'0, w32:'0, w64:'0, w65:'0 };
  parameter wide_t W_XZ    = '{ w1:'x, w3:'z, w8:'x, w32:'z, w64:'x, w65:'z };
  parameter wide_t W_SIZED = '{ w1:1'b1, w3:3'h5, w8:8'hA5, w32:32'd7,
                                w64:64'hFF, w65:65'h1 };
  parameter wide_t W_DEC   = '{ w1:1, w3:5, w8:165, w32:7, w64:255, w65:1 };
endpackage

module child2_107 (
  input pg2_107::wide_t a, input pg2_107::wide_t b, input pg2_107::wide_t c,
  input pg2_107::wide_t d, input pg2_107::wide_t e
);
  logic u; assign u = ^{a,b,c,d,e};
endmodule

module g2_form107 (input logic clk, output logic o);
  child2_107 u_c (
    .a (pg2_107::W_ONES),
    .b (pg2_107::W_ZERO),
    .c (pg2_107::W_XZ),
    .d (pg2_107::W_SIZED),
    .e (pg2_107::W_DEC)
  );
  assign o = clk;
endmodule
