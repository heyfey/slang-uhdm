// r11u62 grid g5 -- THE FENCES of the override-actual encoding law:
// unsized bases, signed bases, >64-bit structs, unions, enum members,
// generate homes, function arguments and localparam hops.
package r62e;
  typedef struct packed { logic [31:0] XLEN; logic [31:0] TID; } cfg_t;
  typedef struct packed { logic [63:0] HI; logic [63:0] LO; } big_t;
  typedef enum logic [3:0] { E0 = 4'd0, E5 = 4'd5 } e_t;
  typedef struct packed { e_t E; logic [27:0] W; } ecfg_t;
  typedef union packed { logic [31:0] A; logic [31:0] B; } un_t;
  function automatic cfg_t build_config();
    cfg_t c; c.XLEN = 32'd64; c.TID = 32'd3; return c;
  endfunction
  function automatic cfg_t build_arg(input int t);
    cfg_t c; c.XLEN = 32'd64; c.TID = t; return c;
  endfunction
  localparam cfg_t CFG = build_config();
endpackage

module e01 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e02 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e03 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e04 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e05 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e06 #(parameter r62e::big_t  P = '0) (output logic o);                  assign o = P.LO[0]; endmodule
module e07 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e08 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e09 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e10 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e12 #(parameter r62e::ecfg_t P = '0) (output logic o);                  assign o = P.W[0];  endmodule
module e13 #(parameter r62e::un_t  P = '0) (output logic o);                   assign o = P.A[0];  endmodule
module e14 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e15 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule
module e16 #(parameter r62e::cfg_t P = r62e::build_config()) (output logic o); assign o = P.TID[0]; endmodule

module tb62e;
  logic w01,w02,w03,w04,w05,w06,w07,w08,w09,w10,w12,w13,w14,w15,w16;
  localparam r62e::cfg_t LC = r62e::CFG;              // a LOCALPARAM hop
  e01 #(.P('b101))                       x01 (.o(w01)); // UNSIZED bin
  e02 #(.P('o27))                        x02 (.o(w02)); // UNSIZED oct
  e03 #(.P('d29))                        x03 (.o(w03)); // UNSIZED 'd
  e04 #(.P('h1F))                        x04 (.o(w04)); // UNSIZED hex
  e05 #(.P(64'sh0000_0020_0000_0031))    x05 (.o(w05)); // SIGNED based hex
  e06 #(.P(128'h0000_0000_0000_0040_0000_0000_0000_0033)) x06 (.o(w06)); // 128-BIT struct
  e07 #(.P(31))                          x07 (.o(w07)); // small BARE decimal
  e08 #(.P(-1))                          x08 (.o(w08)); // NEGATIVE literal
  e09 #(.P(r62e::build_arg(32'd35)))     x09 (.o(w09)); // builder with an ARGUMENT
  e12 #(.P(32'h1000_0037))               x12 (.o(w12)); // struct with an ENUM member
  e13 #(.P(32'h39))                      x13 (.o(w13)); // packed UNION formal
  e14 #(.P(r62e::CFG))                   x14 (.o(w14)); // bare ref (asmEncFollowsRef)
  e15 #(.P(LC))                          x15 (.o(w15)); // a LOCALPARAM hop to it
  e16 #(.P(64'h0000_0040_0000_003B))     x16 (.o(w16)); // plain hex control
  if (1) begin : gblk
    e10 #(.P(64'h0000_0060_0000_003D))   x10 (.o(w10)); // inside a GENERATE block
  end
endmodule
