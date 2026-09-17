// r11u61 h6 — HOLDERS x COPY COUNTS x OVERRIDE at the elaborated face.
// One unpacked struct type; the same pattern carried by an interface, two
// module instances, a generate block, a parameter PORT and an OVERRIDDEN port.
package p6;
  typedef struct { byte b8; shortint s16; int i32; } u6_t;
  localparam u6_t PK = '{b8: 1, s16: 2, i32: 3};
endpackage

interface if6 import p6::*; (input logic clk);
  localparam u6_t IF = '{b8: 4, s16: 5, i32: 6};
endinterface

module h6child import p6::*; #(parameter u6_t PP = '{b8: 7, s16: 8, i32: 9})
                             (input logic clk);
  localparam u6_t CH = '{b8: 10, s16: 11, i32: 12};
  wire z = clk ^ PP.b8[0] ^ CH.b8[0];
endmodule

module h6 import p6::*; (input logic clk);
  localparam u6_t TOPL = '{b8: 13, s16: 14, i32: 15};
  if6 i0 (.clk(clk));
  h6child c0 (.clk(clk));
  h6child #(.PP('{b8: 16, s16: 17, i32: 18})) c1 (.clk(clk));
  genvar g;
  generate
    for (g = 0; g < 2; g++) begin : gb
      localparam u6_t GL = '{b8: 19, s16: 20, i32: 21};
      wire y = clk ^ GL.b8[0];
    end
  endgenerate
  wire z = clk ^ TOPL.b8[0] ^ PK.b8[0];
endmodule
