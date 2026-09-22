// r11u85 a4 -- the MODULE twin of a1/a2/a3: the same Rhs shapes and the same
// drive fields in a MODULE body.  The attribution control -- if the module
// home carries them on both sides, the gap is the interface clone's.
package pk;
  typedef enum logic [1:0] { EA, EB = 2 } e_t;
endpackage

module sub (output logic [31:0] o);
  logic [31:0] c_none;
  logic [31:0] c_del;
  logic [31:0] c_str;
  logic [31:0] e_del;
  wire  [31:0] w_nd = 32'd11;
  assign c_none = 32'd7;
  assign #5 c_del = 32'd8;
  assign (strong1, weak0) c_str = 32'd9;
  assign #5 e_del = pk::EB;
  assign o = c_none ^ c_del ^ c_str ^ e_del ^ w_nd;
endmodule

module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
