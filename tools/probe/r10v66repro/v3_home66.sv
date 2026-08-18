// r10v66 arm 3 — HOMES: module-local / $unit / package (wildcard, explicit,
// qualified) enums x module body, gen-for, gen-if, gen-case, nested gen,
// three instances and an instance array.
typedef enum logic [3:0] { GU = 4'h6, GV = 4'b0011 } gu_t;   // $unit scope

package vpk3;
  typedef enum logic [3:0] { QH = 4'h4, QB = 4'b0110, QD = 4'd9 } q4_t;
endpackage

module vk3 (input logic y1, input logic y2, input logic y3, input logic y4);
endmodule

module vtop3;
  import vpk3::QH;
  import vpk3::*;
  typedef enum logic [3:0] { MH = 4'h5, MB = 4'b1001 } m4_t;
  localparam int NI = 3;
  logic [255:0] bus;

  // module body: module-local, $unit, wildcard, explicit, qualified
  vk3 u_a (.y1(bus[MH]), .y2(bus[GU]), .y3(bus[QB]), .y4(bus[vpk3::QD]));
  vk3 u_b (.y1(bus[MB]), .y2(bus[GV]), .y3(bus[QH]), .y4(bus[vpk3::QH]));
  vk3 u_c (.y1(bus[MH]), .y2(bus[GU]), .y3(bus[QB]), .y4(bus[vpk3::QD]));
  vk3 u_arr [1:0] (.y1(bus[MH]), .y2(bus[GU]), .y3(bus[QB]), .y4(bus[vpk3::QD]));

  // gen-for
  for (genvar gi = 0; gi < NI; gi++) begin : g_for
    vk3 u_f (.y1(bus[MH + gi]), .y2(bus[GU]), .y3(bus[QB]), .y4(bus[vpk3::QD]));
  end

  // gen-if
  if (NI == 3) begin : g_if
    vk3 u_i (.y1(bus[MH]), .y2(bus[GU]), .y3(bus[QB]), .y4(bus[vpk3::QD]));
  end else begin : g_ie
    vk3 u_i (.y1(bus[MB]), .y2(bus[GV]), .y3(bus[QH]), .y4(bus[vpk3::QH]));
  end

  // gen-case
  case (NI)
    3: begin : g_cs
      vk3 u_k (.y1(bus[MH]), .y2(bus[GU]), .y3(bus[QB]), .y4(bus[vpk3::QD]));
    end
    default: begin : g_cd
      vk3 u_k (.y1(bus[MB]), .y2(bus[GV]), .y3(bus[QH]), .y4(bus[vpk3::QH]));
    end
  endcase

  // nested gen
  for (genvar gj = 0; gj < 2; gj++) begin : g_out
    if (gj == 0) begin : g_in
      vk3 u_n (.y1(bus[MH]), .y2(bus[GU]), .y3(bus[QB]), .y4(bus[vpk3::QD]));
    end
  end
endmodule
