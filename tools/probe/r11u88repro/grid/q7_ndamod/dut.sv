// r11u88 q7 -- the MODULE twin of q1/q2: the attribution control.  If the
// module home is byte-identical to golden on these shapes the gap is the
// interface listing's.
package pk;
  typedef enum logic [1:0] { EA, EB = 2 } e_t;
  localparam int PK = 7;
endpackage

module sub (output logic [31:0] o);
  localparam int K = 5;
  wire [31:0] a;
  wire [31:0] b;
  wire [31:0] w_nd  = 32'd11;
  wire [31:0] w_nde = pk::EB;
  wire [31:0] w_uns = 12;
  wire [31:0] w_par = K;
  wire [31:0] w_op  = a ^ b;
  wire [31:0] w_pkg = pk::PK;
  wire [31:0] #3 w_dd = 32'd12;
  logic [31:0] c_plain;
  assign c_plain = 32'd13;
  assign o = w_nd ^ w_nde ^ w_uns ^ w_par ^ w_op ^ w_pkg ^ w_dd ^ c_plain;
endmodule

module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
