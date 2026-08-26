// r10v99 ADVERSARIAL -- the two arithmetic corrections on the LANDED DIRECT
// carrier (no ternary anywhere): getMask's 64-bit saturation and the size
// walk's abort at a member >= 65 bits.  Pristine-vs-patched MUST be scored
// against golden, not merely observed.
package pm99;
  typedef struct packed { logic [127:0] a128; logic [64:0] b65; logic [7:0] c8; } w3_t;
  typedef struct packed { logic [64:0] a65;  logic [7:0] b8; } w2_t;
  typedef struct packed { logic [63:0] a64;  logic [7:0] b8; } n2_t;
  typedef struct packed { logic [7:0] p8; logic [64:0] q65; logic [3:0] r4; } m3_t;
endpackage
module v99_mask (input logic clk,
                 output pm99::w3_t o1, output pm99::w2_t o2,
                 output pm99::n2_t o3, output pm99::w2_t o4,
                 output pm99::w3_t o5, output pm99::m3_t o6,
                 output pm99::m3_t o7);
  assign o1 = '{ default : '1 };                     // 128/65/8 default fill
  assign o2 = '{ a65 : '1, b8 : '1 };                // tagged 65-bit
  assign o3 = '{ a64 : '1, b8 : '1 };                // 64-bit boundary: no delta
  assign o4 = '{ a65 : 65'd3, b8 : 8'hAA };          // sized: size-walk abort only
  assign o5 = '{ default : '0 };
  assign o6 = '{ p8 : '1, q65 : '1, r4 : '1 };       // abort AFTER a leading member
  assign o7 = '{ p8 : 8'h0F, q65 : 65'd1, r4 : 4'h3 };
endmodule
