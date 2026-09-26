// § defGenSelBaseLeafAtIndex164 — a packed union member as the selected leaf of a genvar-selected base
module top(output logic [7:0] o);
  typedef union packed { logic [1:0] f; logic [1:0] h; } u_t;
  u_t [3:0] s;
  for (genvar i = 0; i < 4; i++) begin : g
    assign s[i].f[0] = 1'b1;
    assign s[i].f[1] = 1'b0;
  end
  assign o = s;
endmodule
