// § defGenSelBaseLeafAtIndex164 — the target inside a gen-case nested in the gen-for
module top(output logic [7:0] o);
  typedef struct packed { logic [1:0] f; } e_t;
  e_t [3:0] s;
  for (genvar i = 0; i < 4; i++) begin : g
    case (i % 2)
      0: begin : ev
        assign s[i].f[0] = 1'b1;
        assign s[i].f[1] = 1'b1;
      end
      default: begin : od
        assign s[i].f[0] = 1'b0;
        assign s[i].f[1] = 1'b0;
      end
    endcase
  end
  assign o = s;
endmodule
