// § defGenTargetIpsDefName205 — r11u217 i02: an indexed part-select target on an INTERFACE instance member `b.d[4+:4]` and on a packed-array element member `pa[1].f[0+:4]` inside a case-generate
typedef struct packed { logic [7:0] f; } e_t;
interface bi;
  logic [7:0] d;
endinterface
module top #(parameter int M = 2) (input logic [3:0] i, output logic [7:0] o, output e_t [1:0] pa);
  bi b();
  assign b.d[3:0] = 4'd0;
  assign pa[0] = '0;
  assign pa[1].f[7:4] = 4'd0;
  case (M)
    2: begin : gc
      assign b.d[4+:4] = i;
      assign pa[1].f[0+:4] = i;
    end
    default: begin : gd
      assign b.d[7:4] = 4'd0;
      assign pa[1].f[3:0] = 4'd0;
    end
  endcase
  assign o = b.d;
endmodule
