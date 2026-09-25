// § defGenLhsHpBaseAnchor144
module dut(input logic [1:0] a, output logic [3:0] o);
  typedef struct packed { logic f; logic g; } s_t;
  s_t [1:0] s;
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 0) begin : z
      assign s[i].f = a[i];
    end else begin : nz
      assign s[i].f = ~a[i];
    end
    assign s[i].g = 1'b0;
  end
  assign o = s;
endmodule
