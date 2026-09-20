// v11u66 adversarial arm a1 — THE DIGIT RULE, DISAMBIGUATED.
// Every cell of the implementer's g3_neg66 is consistent with BOTH readings:
//   (a) the digits are the SETTER's own full value  (-3)
//   (b) the digits are the MEMBER-MASKED value read as SIGNED at the member
//       width (253 as s8 = -3, 65533 as s16 = -3, ...)
// because every value it measured FITS the member.  This arm overflows the
// member, where the two readings disagree, and asks golden.
package qa1;
  localparam int K  = 200;
  localparam int KB = 3;
  typedef struct packed {
    logic [7:0]        o8;   // K * 2 = 400   (a) INT:400  (b) 144 -> s8 = -112
    logic signed [7:0] s8;   // K * 2 = 400   the same onto a SIGNED member
    logic [3:0]        o4;   // KB * 7 = 21   (a) INT:21   (b) 5
    logic [15:0]       o16;  // K * 2 = 400   FITS -- control
    logic [7:0]        n8;   // 0 - 300 = -300 (a) INT:-300 (b) 212 -> s8 = -44
    logic [31:0]       ctl;  // K - 1 = 199   FITS -- control
  } ca1_t;
  localparam ca1_t A1 = '{o8: K*2, s8: K*2, o4: KB*7, o16: K*2,
                          n8: 0-300, ctl: K-1};
endpackage
module a1_ovf66 #(parameter qa1::ca1_t C = qa1::A1)
                (output logic [31:0] y0, output logic [31:0] y1,
                 output logic [31:0] y2, output logic [31:0] y3,
                 output logic [31:0] y4, output logic [31:0] y5);
  assign y0 = C.o8;  assign y1 = C.s8;  assign y2 = C.o4;
  assign y3 = C.o16; assign y4 = C.n8;  assign y5 = C.ctl;
endmodule
