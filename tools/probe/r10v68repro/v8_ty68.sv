// r10v68 arm v8 — more Lhs DECLARATION kinds: packed union, 2-D packed,
// typedef chain, `reg`, `wire signed`, an INTERFACE-body variable assigned from
// an interface gen scope, and a variable of a parameterised width.
// MEASUREMENT ONLY.
typedef logic [11:0] v8_t12;
typedef v8_t12       v8_alias;
typedef union packed { logic [7:0] a; logic [7:0] b; } v8_u8;

interface v8_if68;
  logic [7:0] ibody;                      // interface-BODY variable
  for (genvar i = 6; i < 7; i++) begin : g
    if (i > 0) begin : b1
      logic [7:0] igen;                   // gen-LOCAL inside an interface
      assign ibody = i;                   // interface-body Lhs
      assign igen  = i;                   // gen-local Lhs
    end
  end
endinterface

module v8_ty68 #(parameter int unsigned PW = 6) (output logic [7:0] o);
  v8_u8            uu;
  logic [3:0][7:0] p2d;
  v8_alias         al;
  reg   [7:0]      rg;
  wire  signed [7:0] ws;
  logic [PW-1:0]   pw;
  logic [7:0]      mv;
  v8_if68 the_if ();
  for (genvar i = 9; i < 10; i++) begin : g_t
    if (i > 0) begin : b1
      assign uu  = i;                     // packed UNION  (8)
      assign p2d = i;                     // 2-D packed    (32)
      assign al  = i;                     // typedef chain (12)
      assign rg  = i;                     // reg           (8)
      assign ws  = i;                     // wire signed   (8)
      assign pw  = i;                     // parameterised (6)
      assign mv  = i;                     // plain         (8)
    end
  end
  assign o = uu.a ^ p2d[0] ^ al[7:0] ^ rg ^ ws ^ {2'b0, pw} ^ mv ^
             the_if.ibody ^ the_if.g[6].b1.igen;
endmodule
